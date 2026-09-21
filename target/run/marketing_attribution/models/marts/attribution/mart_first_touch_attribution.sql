
  
    

    create or replace table `project-b8fc8724-8adc-4499-9a4`.`ANALYTICS`.`mart_first_touch_attribution`
      
    
    

    
    OPTIONS(
      description="""Model A \u2014 100% credit to first touchpoint"""
    )
    as (
      

-- Model A: 100% credit to the first touchpoint in each conversion path.

with first_touches as (
    select
        conversion_id,
        user_id,
        channel,
        revenue
    from `project-b8fc8724-8adc-4499-9a4`.`raw`.`int_conversion_paths`
    where is_first_touch
)

select
    'first_touch'                                  as model,
    channel,
    count(distinct conversion_id)                  as attributed_conversions,
    sum(revenue)                                   as attributed_revenue,
    

    SAFE_DIVIDE(
        CAST(sum(revenue) AS FLOAT64),
        CAST((select sum(revenue) from first_touches) AS FLOAT64)
    )

 as attributed_share
from first_touches
group by channel
order by attributed_revenue desc
    );
  