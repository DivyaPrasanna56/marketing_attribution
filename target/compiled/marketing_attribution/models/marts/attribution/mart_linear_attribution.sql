

-- Model C: revenue distributed equally across all touchpoints in the path.

with path_credits as (
    select
        conversion_id,
        channel,
        -- Each touchpoint receives revenue / path_length
        sum(revenue / nullif(path_length, 0)) as channel_revenue
    from `project-b8fc8724-8adc-4499-9a4`.`raw`.`int_conversion_paths`
    group by conversion_id, channel
)

select
    'linear'                                       as model,
    channel,
    count(distinct conversion_id)                  as attributed_conversions,
    sum(channel_revenue)                           as attributed_revenue,
    

    SAFE_DIVIDE(
        CAST(sum(channel_revenue) AS FLOAT64),
        CAST((select sum(channel_revenue) from path_credits) AS FLOAT64)
    )

 as attributed_share
from path_credits
group by channel
order by attributed_revenue desc