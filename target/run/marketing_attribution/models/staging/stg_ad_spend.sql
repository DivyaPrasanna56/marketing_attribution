
  create or replace   view MARKETING_DB.RAW.stg_ad_spend
  
    
    
(
  
    "SPEND_ID" COMMENT $$$$, 
  
    "SPEND_DATE" COMMENT $$$$, 
  
    "CHANNEL" COMMENT $$$$, 
  
    "CAMPAIGN_ID" COMMENT $$$$, 
  
    "SPEND_AMOUNT" COMMENT $$$$, 
  
    "IMPRESSIONS" COMMENT $$$$, 
  
    "CLICKS" COMMENT $$$$, 
  
    "CTR" COMMENT $$$$
  
)

   as (
    

select
    spend_id,
    spend_date,
    channel,
    campaign_id,
    spend_amount,
    impressions,
    clicks,
    
    case when nullif(impressions, 0) = 0 or nullif(impressions, 0) is null
         then null
         else (clicks)::float / (nullif(impressions, 0))::float
    end
 as ctr,

from MARKETING_DB.RAW.raw_ad_spend
  );

