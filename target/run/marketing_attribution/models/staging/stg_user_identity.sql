

  create or replace view `project-b8fc8724-8adc-4499-9a4`.`raw`.`stg_user_identity`
  OPTIONS(
      description=""""""
    )
  as 

select
    user_id,
    canonical_user_id,
    email_hash,
    first_seen_at,
    last_seen_at,

from `project-b8fc8724-8adc-4499-9a4`.`raw`.`raw_user_identity`;

