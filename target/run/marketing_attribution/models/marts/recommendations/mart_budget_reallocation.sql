
  
    

    create or replace table `project-b8fc8724-8adc-4499-9a4`.`ANALYTICS`.`mart_budget_reallocation`
      
    
    

    
    OPTIONS(
      description="""Recommended budget per channel, by attribution model"""
    )
    as (
      

with cmp as (
    select * from `project-b8fc8724-8adc-4499-9a4`.`ANALYTICS`.`mart_channel_roas_compared`
),
spend_total as (
    select sum(total_spend) as budget from cmp
),
realloc as (
    select
        c.model,
        c.channel,
        c.total_spend                                                        as current_spend,
        c.attributed_share,
        round(c.attributed_share * (select budget from spend_total), 2)      as recommended_spend,
        round(c.attributed_share * (select budget from spend_total) - c.total_spend, 2)
                                                                             as recommended_change_inr,
        case
            when c.total_spend = 0 then null
            else (c.attributed_share * (select budget from spend_total) - c.total_spend)
                 / c.total_spend
        end                                                                  as recommended_change_pct
    from cmp c
    where c.total_spend is not null
)
select *
from realloc
order by model, recommended_change_pct desc nulls last
    );
  