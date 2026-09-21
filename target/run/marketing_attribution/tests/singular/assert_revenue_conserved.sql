
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from `project-b8fc8724-8adc-4499-9a4`.`dbt_test_failures`.`assert_revenue_conserved`
    
      
    ) dbt_internal_test