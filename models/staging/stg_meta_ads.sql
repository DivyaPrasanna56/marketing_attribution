{{ config(materialized='view') }}

select
    meta_event_id                   as channel_event_id,
    'meta_ads'                      as channel,
    user_id,
    campaign_id,
    ad_set_id                       as group_id,
    ad_id                           as creative_id,
    NULL                            as keyword,
    placement,
    event_type,
    event_timestamp,
    cost,

from {{ source('raw', 'raw_meta_ads') }}
