

  create or replace view `project-b8fc8724-8adc-4499-9a4`.`raw`.`stg_tiktok_ads`
  OPTIONS(
      description=""""""
    )
  as 

select
    tiktok_event_id                 as channel_event_id,
    'tiktok_ads'                    as channel,
    user_id,
    campaign_id,
    ad_group_id                     as group_id,
    creative_id,
    NULL                            as keyword,
    NULL                            as placement,
    event_type,
    event_timestamp,
    cost,

from `project-b8fc8724-8adc-4499-9a4`.`raw`.`raw_tiktok_ads`;

