

select
    google_event_id                 as channel_event_id,
    'google_ads'                    as channel,
    user_id,
    campaign_id,
    ad_group_id                     as group_id,
    creative_id,
    keyword,
    NULL                            as placement,
    event_type,
    event_timestamp,
    cost,

from MARKETING_DB.RAW.raw_google_ads