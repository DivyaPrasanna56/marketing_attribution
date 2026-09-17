select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from MARKETING_DB.dbt_test_failures.dbt_utils_expression_is_true_stg_conversions_revenue___0
    
      
    ) dbt_internal_test