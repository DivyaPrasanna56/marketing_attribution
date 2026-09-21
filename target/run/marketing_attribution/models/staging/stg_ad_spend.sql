

  create or replace view `project-b8fc8724-8adc-4499-9a4`.`raw`.`stg_ad_spend`
  OPTIONS(
      description=""""""
    )
  as 

select
    spend_id,
    spend_date,
    channel,
    campaign_id,
    spend_amount,
    impressions,
    clicks,
    

    SAFE_DIVIDE(
        CAST(clicks AS FLOAT64),
        CAST(nullif(impressions, 0) AS FLOAT64)
    )

 as ctr,

from `project-b8fc8724-8adc-4499-9a4`.`raw`.`raw_ad_spend`;

