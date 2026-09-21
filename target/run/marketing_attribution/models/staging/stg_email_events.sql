

  create or replace view `project-b8fc8724-8adc-4499-9a4`.`raw`.`stg_email_events`
  OPTIONS(
      description=""""""
    )
  as 

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

from `project-b8fc8724-8adc-4499-9a4`.`raw`.`raw_email_events`;

