

select
    conversion_id,
    user_id,
    conversion_type,
    revenue,
    conversion_timestamp,
    cast(conversion_timestamp as date)  as conversion_date,

from MARKETING_DB.RAW.raw_conversions