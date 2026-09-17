

select
    event_id                        as channel_event_id,
    'web'                           as channel,
    user_id,
    utm_campaign                    as campaign_id,
    NULL                            as group_id,
    NULL                            as creative_id,
    NULL                            as keyword,
    NULL                            as placement,
    event_type,
    event_timestamp,
    0.0                             as cost,
    -- web-specific extras
    session_id,
    page_url,
    referrer,
    utm_source,
    utm_medium,
    payload,

from MARKETING_DB.RAW.raw_web_events