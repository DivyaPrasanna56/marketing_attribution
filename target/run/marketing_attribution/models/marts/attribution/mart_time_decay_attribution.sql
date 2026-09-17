
  
    

        create or replace transient table MARKETING_DB.ANALYTICS.mart_time_decay_attribution
         as
        (

-- Model D: exponentially-weighted credit, with touchpoints closer to
-- conversion receiving more weight. Half-life is configurable.

with weighted as (
    select
        conversion_id,
        channel,
        hours_to_conversion,
        revenue,
        -- exp(-h / (half_life * 24))   →   half_life days
        exp(-hours_to_conversion / (7 * 24.0)) as raw_weight
    from MARKETING_DB.RAW.int_conversion_paths
),

normalized as (
    select
        conversion_id,
        channel,
        revenue * raw_weight / sum(raw_weight) over (partition by conversion_id) as channel_revenue
    from weighted
)

select
    'time_decay'                                   as model,
    channel,
    count(distinct conversion_id)                  as attributed_conversions,
    sum(channel_revenue)                           as attributed_revenue,
    
    case when (select sum(channel_revenue) from normalized) = 0 or (select sum(channel_revenue) from normalized) is null
         then null
         else (sum(channel_revenue))::float / ((select sum(channel_revenue) from normalized))::float
    end
 as attributed_share
from normalized
group by channel
order by attributed_revenue desc
        );
      
  