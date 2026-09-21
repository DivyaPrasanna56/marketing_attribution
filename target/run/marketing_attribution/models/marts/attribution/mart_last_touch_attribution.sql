
  
    

    create or replace table `project-b8fc8724-8adc-4499-9a4`.`ANALYTICS`.`mart_last_touch_attribution`
      
    
    

    
    OPTIONS(
      description="""Model B \u2014 100% credit to last touchpoint"""
    )
    as (
      

-- Model B: 100% credit to the last touchpoint in each conversion path.

with last_touches as (
    select
        conversion_id,
        user_id,
        channel,
        revenue
    from `project-b8fc8724-8adc-4499-9a4`.`raw`.`int_conversion_paths`
    where is_last_touch
)

select
    'last_touch'                                   as model,
    channel,
    count(distinct conversion_id)                  as attributed_conversions,
    sum(revenue)                                   as attributed_revenue,
    

    SAFE_DIVIDE(
        CAST(sum(revenue) AS FLOAT64),
        CAST((select sum(revenue) from last_touches) AS FLOAT64)
    )

 as attributed_share
from last_touches
group by channel
order by attributed_revenue desc
    );
  