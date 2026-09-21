

  create or replace view `project-b8fc8724-8adc-4499-9a4`.`raw`.`stg_conversions`
  OPTIONS(
      description=""""""
    )
  as 

select
    conversion_id,
    user_id,
    conversion_type,
    revenue,
    conversion_timestamp,
    cast(conversion_timestamp as date)  as conversion_date,

from `project-b8fc8724-8adc-4499-9a4`.`raw`.`raw_conversions`;

