select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from MARKETING_DB.dbt_test_failures.unique_channels_channel
    
      
    ) dbt_internal_test