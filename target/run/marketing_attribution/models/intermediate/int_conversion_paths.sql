
  
    

        create or replace transient table MARKETING_DB.RAW.int_conversion_paths
         as
        (

-- =====================================================================
-- For each conversion, produce the ordered touchpoint path that preceded
-- it within the attribution window (default 30 days).
-- This is the core input for all 5 attribution models.
-- =====================================================================

with  __dbt__cte__int_unified_touchpoints as (


-- =====================================================================
-- Unify all 5 source channels into a single touchpoint schema.
-- This is the table that all attribution models query.
-- =====================================================================

with google as (
    select channel_event_id, channel, user_id, campaign_id, group_id, creative_id,
           keyword, placement, event_type, event_timestamp, cost
    from MARKETING_DB.RAW.stg_google_ads
),
meta as (
    select channel_event_id, channel, user_id, campaign_id, group_id, creative_id,
           keyword, placement, event_type, event_timestamp, cost
    from MARKETING_DB.RAW.stg_meta_ads
),
tiktok as (
    select channel_event_id, channel, user_id, campaign_id, group_id, creative_id,
           keyword, placement, event_type, event_timestamp, cost
    from MARKETING_DB.RAW.stg_tiktok_ads
),
email as (
    select channel_event_id, channel, user_id, campaign_id, group_id, creative_id,
           keyword, placement, event_type, event_timestamp, cost
    from MARKETING_DB.RAW.stg_email_events
),
web as (
    select channel_event_id, channel, user_id, campaign_id, group_id, creative_id,
           keyword, placement, event_type, event_timestamp, cost
    from MARKETING_DB.RAW.stg_web_events
),

unioned as (
    select * from google
    union all select * from meta
    union all select * from tiktok
    union all select * from email
    union all select * from web
),

-- Filter to interaction-style events only (drop pure impressions for cleaner attribution paths)
filtered as (
    select *
    from unioned
    where event_type in ('click', 'open', 'view', 'product_view', 'add_to_cart', 'page_view')
)

select * from filtered
), conversions as (
    select * from MARKETING_DB.RAW.stg_conversions
),

touchpoints as (
    select * from __dbt__cte__int_unified_touchpoints
),

-- Join conversions to all preceding touchpoints from the same user within the window
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
        datediff('hour', t.event_timestamp, c.conversion_timestamp) as hours_to_conversion
    from conversions c
    inner join touchpoints t
       on c.user_id = t.user_id
      and t.event_timestamp <= c.conversion_timestamp
      and t.event_timestamp >= dateadd('day', -30, c.conversion_timestamp)
),

with_position as (
    select
        *,
        row_number() over (partition by conversion_id order by event_timestamp asc)  as touch_position,
        count(*)     over (partition by conversion_id)                               as path_length,
        row_number() over (partition by conversion_id order by event_timestamp desc) as touch_position_from_end
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
    case when touch_position = 1                  then true else false end as is_first_touch,
    case when touch_position_from_end = 1         then true else false end as is_last_touch
from with_position
        );
      
  