-- Total revenue must be conserved across all 5 attribution models.
-- (Each model redistributes the same revenue universe; sums should be ≈ equal.)

with totals as (
    select model, sum(attributed_revenue) as total_attributed
      from `project-b8fc8724-8adc-4499-9a4`.`ANALYTICS`.`mart_channel_roas_compared`
     group by 1
),
expected as (
    select sum(revenue) as expected_total from `project-b8fc8724-8adc-4499-9a4`.`raw`.`stg_conversions`
)
select t.model, t.total_attributed, e.expected_total,
       abs(t.total_attributed - e.expected_total) as delta
  from totals t
 cross join expected e
 where abs(t.total_attributed - e.expected_total) > e.expected_total * 0.20