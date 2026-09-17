
  create or replace   view MARKETING_DB.RAW.stg_conversions
  
    
    
(
  
    "CONVERSION_ID" COMMENT $$$$, 
  
    "USER_ID" COMMENT $$$$, 
  
    "CONVERSION_TYPE" COMMENT $$$$, 
  
    "REVENUE" COMMENT $$$$, 
  
    "CONVERSION_TIMESTAMP" COMMENT $$$$, 
  
    "CONVERSION_DATE" COMMENT $$$$
  
)

   as (
    

select
    conversion_id,
    user_id,
    conversion_type,
    revenue,
    conversion_timestamp,
    cast(conversion_timestamp as date)  as conversion_date,

from MARKETING_DB.RAW.raw_conversions
  );

