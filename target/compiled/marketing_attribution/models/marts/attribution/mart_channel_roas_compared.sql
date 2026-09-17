

-- =====================================================================
-- The dissertation's headline output: same revenue, five attribution
-- views side by side, plus channel cost and ROAS for each.
-- =====================================================================

with all_models as (
    select model, channel, attributed_conversions, attributed_revenue, attributed_share
      from MARKETING_DB.ANALYTICS.mart_first_touch_attribution
    union all
    select model, channel, attributed_conversions, attributed_revenue, attributed_share
      from MARKETING_DB.ANALYTICS.mart_last_touch_attribution
    union all
    select model, channel, attributed_conversions, attributed_revenue, attributed_share
      from MARKETING_DB.ANALYTICS.mart_linear_attribution
    union all
    select model, channel, attributed_conversions, attributed_revenue, attributed_share
      from MARKETING_DB.ANALYTICS.mart_time_decay_attribution
    union all
    select model, channel, attributed_conversions, attributed_revenue, attributed_share
      from MARKETING_DB.ANALYTICS.mart_markov_attribution
),

channel_spend as (
    select channel, sum(spend_amount) as total_spend
      from MARKETING_DB.RAW.stg_ad_spend
     group by 1
)

select
    a.model,
    a.channel,
    a.attributed_conversions,
    a.attributed_revenue,
    a.attributed_share,
    coalesce(s.total_spend, 0)                                  as total_spend,
    
    case when nullif(s.total_spend, 0) = 0 or nullif(s.total_spend, 0) is null
         then null
         else (a.attributed_revenue)::float / (nullif(s.total_spend, 0))::float
    end
 as roas
from all_models a
left join channel_spend s on a.channel = s.channel
order by a.model, a.attributed_revenue desc