
  
    

        create or replace transient table MARKETING_DB.ANALYTICS.mart_first_touch_attribution
         as
        (

-- Model A: 100% credit to the first touchpoint in each conversion path.

with first_touches as (
    select
        conversion_id,
        user_id,
        channel,
        revenue
    from MARKETING_DB.RAW.int_conversion_paths
    where is_first_touch
)

select
    'first_touch'                                  as model,
    channel,
    count(distinct conversion_id)                  as attributed_conversions,
    sum(revenue)                                   as attributed_revenue,
    
    case when (select sum(revenue) from first_touches) = 0 or (select sum(revenue) from first_touches) is null
         then null
         else (sum(revenue))::float / ((select sum(revenue) from first_touches))::float
    end
 as attributed_share
from first_touches
group by channel
order by attributed_revenue desc
        );
      
  