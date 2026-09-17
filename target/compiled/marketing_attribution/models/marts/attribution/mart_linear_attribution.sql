

-- Model C: revenue distributed equally across all touchpoints in the path.

with path_credits as (
    select
        conversion_id,
        channel,
        -- Each touchpoint receives revenue / path_length
        sum(revenue / nullif(path_length, 0)) as channel_revenue
    from MARKETING_DB.RAW.int_conversion_paths
    group by conversion_id, channel
)

select
    'linear'                                       as model,
    channel,
    count(distinct conversion_id)                  as attributed_conversions,
    sum(channel_revenue)                           as attributed_revenue,
    
    case when (select sum(channel_revenue) from path_credits) = 0 or (select sum(channel_revenue) from path_credits) is null
         then null
         else (sum(channel_revenue))::float / ((select sum(channel_revenue) from path_credits))::float
    end
 as attributed_share
from path_credits
group by channel
order by attributed_revenue desc