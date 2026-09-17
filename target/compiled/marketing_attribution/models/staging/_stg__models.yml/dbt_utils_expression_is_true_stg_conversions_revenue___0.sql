



select
    *
from MARKETING_DB.RAW.stg_conversions

where not(revenue >= 0)

