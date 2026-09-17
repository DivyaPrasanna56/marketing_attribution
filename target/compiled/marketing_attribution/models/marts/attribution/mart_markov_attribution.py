"""
mart_markov_attribution.py
Snowpark Python dbt model for Markov-chain attribution.

The Markov-chain method (Anderl et al., 2016; Shao & Li, 2011) computes each
channel's contribution to overall conversion probability via a removal-effect
analysis:

  1. Build a transition matrix from observed paths: states = {channels} +
     {start, conversion, null}.
  2. Compute baseline conversion probability of the full graph.
  3. For each channel C, "remove" C from the graph and re-compute conversion
     probability. The drop equals C's contribution.
  4. Normalise contributions to 1.0; multiply by total revenue.
"""

import pandas as pd
import numpy as np


def model(dbt, session):
    dbt.config(
        materialized="table",
        packages=["snowflake-snowpark-python", "pandas", "numpy"],
        tags=["attribution", "markov", "intervention"]
    )

    paths_df = dbt.ref("int_conversion_paths").to_pandas()
    paths_df.columns = [c.lower() for c in paths_df.columns]

    # Order touchpoints by conversion + position
    paths_df = paths_df.sort_values(["conversion_id", "touch_position"])

    # Build per-conversion path lists
    conversions = paths_df.groupby("conversion_id").agg(
        path=("channel", list),
        revenue=("revenue", "first"),
    ).reset_index()

    # Total revenue (the universe to redistribute)
    total_revenue = float(conversions["revenue"].sum())

    # All distinct channels (states)
    channels = sorted(set(c for path in conversions["path"] for c in path))
    states = ["START"] + channels + ["CONVERSION"]
    state_idx = {s: i for i, s in enumerate(states)}
    n = len(states)

    # ---- Build transition matrix from observed paths -----------------
    transitions = np.zeros((n, n), dtype=float)
    # Add a NULL state for non-converters? Skip — we only have converters.
    # Each path: START -> ch1 -> ch2 -> ... -> chN -> CONVERSION
    for path in conversions["path"]:
        prev = "START"
        for ch in path:
            transitions[state_idx[prev], state_idx[ch]] += 1
            prev = ch
        transitions[state_idx[prev], state_idx["CONVERSION"]] += 1

    # Row-normalise to probabilities
    row_sums = transitions.sum(axis=1, keepdims=True)
    row_sums[row_sums == 0] = 1.0
    P = transitions / row_sums

    # ---- Baseline conversion probability ------------------------------
    # Compute steady-state probability of reaching CONVERSION from START.
    # Use absorbing-Markov-chain logic: solve fundamental matrix.
    # Simpler: simulate by raising P to a high power.
    def conv_prob(P_mat):
        v = np.zeros(n); v[state_idx["START"]] = 1.0
        for _ in range(50):
            v = v @ P_mat
        return float(v[state_idx["CONVERSION"]])

    baseline = conv_prob(P)

    # ---- Removal-effect per channel -----------------------------------
    contributions = {}
    for ch in channels:
        P_removed = P.copy()
        # Remove channel: redirect all transitions INTO ch to "lost" (to START
        # absorbing on null path = drop to 0). Set its row to all-zero too.
        idx = state_idx[ch]
        P_removed[:, idx] = 0
        P_removed[idx, :] = 0
        # Renormalise
        row_sums = P_removed.sum(axis=1, keepdims=True)
        row_sums[row_sums == 0] = 1.0
        P_removed = P_removed / row_sums
        prob_without = conv_prob(P_removed)
        # Removal effect = (baseline - prob_without) / baseline, clipped to [0, 1]
        contributions[ch] = max(0.0, baseline - prob_without)

    # Normalise so contributions sum to 1.0
    total_contrib = sum(contributions.values())
    if total_contrib == 0:
        normalised = {ch: 1.0 / len(channels) for ch in channels}
    else:
        normalised = {ch: v / total_contrib for ch, v in contributions.items()}

    # Build output dataframe
    rows = []
    for ch in channels:
        share   = float(normalised[ch])
        revenue = round(share * total_revenue, 2)
        rows.append({
            "model": "markov",
            "channel": ch,
            "attributed_conversions": int(len(conversions)),  # all conversions count
            "attributed_revenue": revenue,
            "attributed_share": share,
        })

    out = pd.DataFrame(rows).sort_values("attributed_revenue", ascending=False)
    out.columns = [c.upper() for c in out.columns]

    session.sql("USE SCHEMA ANALYTICS").collect()
    return session.create_dataframe(out)


# This part is user provided model code
# you will need to copy the next section to run the code
# COMMAND ----------
# this part is dbt logic for get ref work, do not modify

def ref(*args, **kwargs):
    refs = {"int_conversion_paths": "MARKETING_DB.RAW.int_conversion_paths"}
    key = '.'.join(args)
    version = kwargs.get("v") or kwargs.get("version")
    if version:
        key += f".v{version}"
    dbt_load_df_function = kwargs.get("dbt_load_df_function")
    return dbt_load_df_function(refs[key])


def source(*args, dbt_load_df_function):
    sources = {}
    key = '.'.join(args)
    return dbt_load_df_function(sources[key])


config_dict = {}


class config:
    def __init__(self, *args, **kwargs):
        pass

    @staticmethod
    def get(key, default=None):
        return config_dict.get(key, default)

class this:
    """dbt.this() or dbt.this.identifier"""
    database = "MARKETING_DB"
    schema = "ANALYTICS"
    identifier = "mart_markov_attribution"
    
    def __repr__(self):
        return 'MARKETING_DB.ANALYTICS.mart_markov_attribution'


class dbtObj:
    def __init__(self, load_df_function) -> None:
        self.source = lambda *args: source(*args, dbt_load_df_function=load_df_function)
        self.ref = lambda *args, **kwargs: ref(*args, **kwargs, dbt_load_df_function=load_df_function)
        self.config = config
        self.this = this()
        self.is_incremental = False

# COMMAND ----------

# To run this in snowsight, you need to select entry point to be main
# And you may have to modify the return type to text to get the result back
# def main(session):
#     dbt = dbtObj(session.table)
#     df = model(dbt, session)
#     return df.collect()

# to run this in local notebook, you need to create a session following examples https://github.com/Snowflake-Labs/sfguide-getting-started-snowpark-python
# then you can do the following to run model
# dbt = dbtObj(session.table)
# df = model(dbt, session)

