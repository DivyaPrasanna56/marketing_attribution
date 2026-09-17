

-- Model B: 100% credit to the last touchpoint in each conversion path.

with last_touches as (
    select
        conversion_id,
        user_id,
        channel,
        revenue
    from MARKETING_DB.RAW.int_conversion_paths
    where is_last_touch
)

select
    'last_touch'                                   as model,
    channel,
    count(distinct conversion_id)                  as attributed_conversions,
    sum(revenue)                                   as attributed_revenue,
    
    case when (select sum(revenue) from last_touches) = 0 or (select sum(revenue) from last_touches) is null
         then null
         else (sum(revenue))::float / ((select sum(revenue) from last_touches))::float
    end
 as attributed_share
from last_touches
group by channel
order by attributed_revenue desc