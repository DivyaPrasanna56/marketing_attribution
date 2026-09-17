
  create or replace   view MARKETING_DB.RAW.stg_email_events
  
    
    
(
  
    "CHANNEL_EVENT_ID" COMMENT $$$$, 
  
    "CHANNEL" COMMENT $$$$, 
  
    "USER_ID" COMMENT $$$$, 
  
    "CAMPAIGN_ID" COMMENT $$$$, 
  
    "GROUP_ID" COMMENT $$$$, 
  
    "CREATIVE_ID" COMMENT $$$$, 
  
    "KEYWORD" COMMENT $$$$, 
  
    "PLACEMENT" COMMENT $$$$, 
  
    "EVENT_TYPE" COMMENT $$$$, 
  
    "EVENT_TIMESTAMP" COMMENT $$$$, 
  
    "COST" COMMENT $$$$
  
)

   as (
    

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

from MARKETING_DB.RAW.raw_email_events
  );

