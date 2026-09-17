select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from MARKETING_DB.dbt_test_failures.unique_stg_conversions_conversion_id
    
      
    ) dbt_internal_test