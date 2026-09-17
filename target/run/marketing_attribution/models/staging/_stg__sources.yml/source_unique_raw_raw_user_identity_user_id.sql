select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from MARKETING_DB.dbt_test_failures.source_unique_raw_raw_user_identity_user_id
    
      
    ) dbt_internal_test