
  
    

    create or replace table `project-b8fc8724-8adc-4499-9a4`.`raw`.`int_path_summary`
      
    
    

    
    OPTIONS(
      description=""""""
    )
    as (
      

-- =====================================================================
-- One row per conversion: the ordered channel sequence as a string.
-- Powers the Markov-chain attribution model.
-- =====================================================================

with paths as (

    select
        conversion_id,
        user_id,
        revenue,

        string_agg(
            cast(channel as string),
            ' > '
            order by event_timestamp asc
        ) as path,

        path_length

    from `project-b8fc8724-8adc-4499-9a4`.`raw`.`int_conversion_paths`

    group by
        conversion_id,
        user_id,
        revenue,
        path_length

),

deduped as (

    select
        conversion_id,
        user_id,
        revenue,
        path,
        path_length

    from paths

)

select *
from deduped
    );
  