

  create or replace view `project-b8fc8724-8adc-4499-9a4`.`raw`.`stg_web_events`
  OPTIONS(
      description=""""""
    )
  as 

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

from `project-b8fc8724-8adc-4499-9a4`.`raw`.`raw_web_events`;

