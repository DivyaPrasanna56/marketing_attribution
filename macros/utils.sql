{% macro safe_divide(numerator, denominator) %}
    case when {{ denominator }} = 0 or {{ denominator }} is null
         then null
         else ({{ numerator }})::float / ({{ denominator }})::float
    end
{% endmacro %}


{% macro create_run_history_table_if_not_exists() %}
    {% set sql %}
        create table if not exists {{ target.database }}.META.dbt_run_history (
            invocation_id    varchar(64),
            run_started_at   timestamp_ltz,
            run_completed_at timestamp_ltz,
            target_name      varchar(64),
            command          varchar(64),
            status           varchar(32),
            num_models_total number,
            num_models_pass  number,
            num_models_fail  number,
            num_models_warn  number,
            execution_time_s number(12, 3)
        )
    {% endset %}
    {% if execute %}
        {% do run_query(sql) %}
    {% endif %}
{% endmacro %}


{% macro insert_run_history_row(results) %}
    {% if execute %}
        {% set total = results | length %}
        {% set passes = results | selectattr('status', 'equalto', 'success') | list | length %}
        {% set fails  = results | selectattr('status', 'equalto', 'error')   | list | length %}
        {% set warns  = results | selectattr('status', 'equalto', 'warn')    | list | length %}
        {% set elapsed = results | sum(attribute='execution_time') %}
        {% set sql %}
            insert into {{ target.database }}.META.dbt_run_history
              (invocation_id, run_started_at, run_completed_at, target_name,
               command, status, num_models_total, num_models_pass,
               num_models_fail, num_models_warn, execution_time_s)
            select '{{ invocation_id }}', '{{ run_started_at }}', current_timestamp(),
                   '{{ target.name }}', '{{ flags.WHICH }}',
                   case when {{ fails }} > 0 then 'error'
                        when {{ warns }} > 0 then 'warn'
                        else 'success' end,
                   {{ total }}, {{ passes }}, {{ fails }}, {{ warns }}, {{ elapsed | round(3) }}
        {% endset %}
        {% do run_query(sql) %}
    {% endif %}
{% endmacro %}
