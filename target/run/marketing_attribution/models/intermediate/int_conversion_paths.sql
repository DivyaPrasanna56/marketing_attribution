
  
    

    create or replace table `project-b8fc8724-8adc-4499-9a4`.`raw`.`int_conversion_paths`
      
    
    

    
    OPTIONS(
      description=""""""
    )
    as (
      

-- =====================================================================
-- For each conversion, produce the ordered touchpoint path that preceded
-- it within the attribution window (default 30 days).
-- This is the core input for all attribution models.
-- =====================================================================

with  __dbt__cte__int_unified_touchpoints as (


-- =====================================================================
-- Unify all 5 source channels into a single touchpoint schema.
-- All UNION columns are explicitly cast to consistent BigQuery types.
-- =====================================================================

with google as (

    select
        cast(channel_event_id as string) as channel_event_id,
        cast(channel as string) as channel,
        cast(user_id as string) as user_id,
        cast(campaign_id as string) as campaign_id,
        cast(group_id as string) as group_id,
        cast(creative_id as string) as creative_id,
        cast(keyword as string) as keyword,
        cast(placement as string) as placement,
        cast(event_type as string) as event_type,
        cast(event_timestamp as timestamp) as event_timestamp,
        cast(cost as float64) as cost
    from `project-b8fc8724-8adc-4499-9a4`.`raw`.`stg_google_ads`

),

meta as (

    select
        cast(channel_event_id as string) as channel_event_id,
        cast(channel as string) as channel,
        cast(user_id as string) as user_id,
        cast(campaign_id as string) as campaign_id,
        cast(group_id as string) as group_id,
        cast(creative_id as string) as creative_id,
        cast(keyword as string) as keyword,
        cast(placement as string) as placement,
        cast(event_type as string) as event_type,
        cast(event_timestamp as timestamp) as event_timestamp,
        cast(cost as float64) as cost
    from `project-b8fc8724-8adc-4499-9a4`.`raw`.`stg_meta_ads`

),

tiktok as (

    select
        cast(channel_event_id as string) as channel_event_id,
        cast(channel as string) as channel,
        cast(user_id as string) as user_id,
        cast(campaign_id as string) as campaign_id,
        cast(group_id as string) as group_id,
        cast(creative_id as string) as creative_id,
        cast(keyword as string) as keyword,
        cast(placement as string) as placement,
        cast(event_type as string) as event_type,
        cast(event_timestamp as timestamp) as event_timestamp,
        cast(cost as float64) as cost
    from `project-b8fc8724-8adc-4499-9a4`.`raw`.`stg_tiktok_ads`

),

email as (

    select
        cast(channel_event_id as string) as channel_event_id,
        cast(channel as string) as channel,
        cast(user_id as string) as user_id,
        cast(campaign_id as string) as campaign_id,
        cast(group_id as string) as group_id,
        cast(creative_id as string) as creative_id,
        cast(keyword as string) as keyword,
        cast(placement as string) as placement,
        cast(event_type as string) as event_type,
        cast(event_timestamp as timestamp) as event_timestamp,
        cast(cost as float64) as cost
    from `project-b8fc8724-8adc-4499-9a4`.`raw`.`stg_email_events`

),

web as (

    select
        cast(channel_event_id as string) as channel_event_id,
        cast(channel as string) as channel,
        cast(user_id as string) as user_id,
        cast(campaign_id as string) as campaign_id,
        cast(group_id as string) as group_id,
        cast(creative_id as string) as creative_id,
        cast(keyword as string) as keyword,
        cast(placement as string) as placement,
        cast(event_type as string) as event_type,
        cast(event_timestamp as timestamp) as event_timestamp,
        cast(cost as float64) as cost
    from `project-b8fc8724-8adc-4499-9a4`.`raw`.`stg_web_events`

),

unioned as (

    select * from google

    union all
    select * from meta

    union all
    select * from tiktok

    union all
    select * from email

    union all
    select * from web

),

filtered as (

    select *
    from unioned
    where event_type in (
        'click',
        'open',
        'view',
        'product_view',
        'add_to_cart',
        'page_view'
    )

)

select *
from filtered
), conversions as (

    select *
    from `project-b8fc8724-8adc-4499-9a4`.`raw`.`stg_conversions`

),

touchpoints as (

    select *
    from __dbt__cte__int_unified_touchpoints

),

-- Join conversions to all preceding touchpoints from the same user
-- within the attribution window.
joined as (

    select
        c.conversion_id,
        c.user_id,
        c.conversion_timestamp,
        c.revenue,
        t.channel_event_id,
        t.channel,
        t.event_timestamp,
        t.campaign_id,

        timestamp_diff(
            c.conversion_timestamp,
            t.event_timestamp,
            hour
        ) as hours_to_conversion

    from conversions c

    inner join touchpoints t
        on c.user_id = t.user_id

        and t.event_timestamp <= c.conversion_timestamp

        and t.event_timestamp >= timestamp_sub(
            c.conversion_timestamp,
            interval 30 day
        )

),

with_position as (

    select
        *,
        
        row_number() over (
            partition by conversion_id
            order by event_timestamp asc
        ) as touch_position,

        count(*) over (
            partition by conversion_id
        ) as path_length,

        row_number() over (
            partition by conversion_id
            order by event_timestamp desc
        ) as touch_position_from_end

    from joined

)

select
    conversion_id,
    user_id,
    conversion_timestamp,
    revenue,
    channel,
    channel_event_id,
    event_timestamp,
    campaign_id,
    hours_to_conversion,
    touch_position,
    path_length,

    case
        when touch_position = 1 then true
        else false
    end as is_first_touch,

    case
        when touch_position_from_end = 1 then true
        else false
    end as is_last_touch

from with_position
    );
  