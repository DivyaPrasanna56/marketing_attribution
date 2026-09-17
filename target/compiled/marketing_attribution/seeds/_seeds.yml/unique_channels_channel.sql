
    
    

select
    channel as unique_field,
    count(*) as n_records

from MARKETING_DB.RAW.channels
where channel is not null
group by channel
having count(*) > 1


