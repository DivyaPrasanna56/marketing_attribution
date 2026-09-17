
  
    

        create or replace transient table MARKETING_DB.RAW.int_path_summary
         as
        (

-- =====================================================================
-- One row per conversion: the ordered channel sequence as a string.
-- Powers the Markov-chain attribution model.
-- =====================================================================

with paths as (
    select
        conversion_id,
        user_id,
        revenue,
        listagg(channel, ' > ') within group (order by event_timestamp asc) as path,
        path_length,
        max(path_length) as actual_length
    from MARKETING_DB.RAW.int_conversion_paths
    group by conversion_id, user_id, revenue, path_length
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

select * from deduped
        );
      
  