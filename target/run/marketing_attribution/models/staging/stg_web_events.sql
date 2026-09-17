
  create or replace   view MARKETING_DB.RAW.stg_web_events
  
    
    
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
  
    "COST" COMMENT $$$$, 
  
    "SESSION_ID" COMMENT $$$$, 
  
    "PAGE_URL" COMMENT $$$$, 
  
    "REFERRER" COMMENT $$$$, 
  
    "UTM_SOURCE" COMMENT $$$$, 
  
    "UTM_MEDIUM" COMMENT $$$$, 
  
    "PAYLOAD" COMMENT $$$$
  
)

   as (
    

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
  );

