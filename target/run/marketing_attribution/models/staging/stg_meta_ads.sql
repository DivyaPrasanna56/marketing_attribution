
  create or replace   view MARKETING_DB.RAW.stg_meta_ads
  
    
    
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

from MARKETING_DB.RAW.raw_meta_ads
  );

