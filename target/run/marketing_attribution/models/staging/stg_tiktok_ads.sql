
  create or replace   view MARKETING_DB.RAW.stg_tiktok_ads
  
    
    
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

from MARKETING_DB.RAW.raw_tiktok_ads
  );

