
  create or replace   view MARKETING_DB.RAW.stg_user_identity
  
    
    
(
  
    "USER_ID" COMMENT $$$$, 
  
    "CANONICAL_USER_ID" COMMENT $$$$, 
  
    "EMAIL_HASH" COMMENT $$$$, 
  
    "FIRST_SEEN_AT" COMMENT $$$$, 
  
    "LAST_SEEN_AT" COMMENT $$$$
  
)

   as (
    

select
    user_id,
    canonical_user_id,
    email_hash,
    first_seen_at,
    last_seen_at,

from MARKETING_DB.RAW.raw_user_identity
  );

