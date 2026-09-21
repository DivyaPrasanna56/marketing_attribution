
  
    

    create or replace table `project-b8fc8724-8adc-4499-9a4`.`ANALYTICS`.`mart_time_decay_attribution`
      
    
    

    
    OPTIONS(
      description="""Model D \u2014 exponentially-decaying credit toward conversion"""
    )
    as (
      

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
    from `project-b8fc8724-8adc-4499-9a4`.`raw`.`int_conversion_paths`
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
    

    SAFE_DIVIDE(
        CAST(sum(channel_revenue) AS FLOAT64),
        CAST((select sum(channel_revenue) from normalized) AS FLOAT64)
    )

 as attributed_share
from normalized
group by channel
order by attributed_revenue desc
    );
  