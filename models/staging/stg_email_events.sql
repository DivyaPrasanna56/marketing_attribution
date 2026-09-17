{{ config(materialized='view') }}

select
    email_event_id                  as channel_event_id,
    'email'                         as channel,
    user_id,
    campaign_id,
    NULL                            as group_id,
    NULL                            as creative_id,
    NULL                            as keyword,
    NULL                            as placement,
    event_type,
    event_timestamp,
    0.0                             as cost,

from {{ source('raw', 'raw_email_events') }}
