

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