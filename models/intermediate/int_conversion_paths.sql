{{ config(materialized='table') }}

-- =====================================================================
-- For each conversion, produce the ordered touchpoint path that preceded
-- it within the attribution window (default 30 days).
-- This is the core input for all attribution models.
-- =====================================================================

with conversions as (

    select *
    from {{ ref('stg_conversions') }}

),

touchpoints as (

    select *
    from {{ ref('int_unified_touchpoints') }}

),

-- Join conversions to all preceding touchpoints from the same user
-- within the attribution window.
joined as (

    select
        c.conversion_id,
        c.user_id,
        c.conversion_timestamp,
        c.revenue,
        t.channel_event_id,
        t.channel,
        t.event_timestamp,
        t.campaign_id,

        timestamp_diff(
            c.conversion_timestamp,
            t.event_timestamp,
            hour
        ) as hours_to_conversion

    from conversions c

    inner join touchpoints t
        on c.user_id = t.user_id

        and t.event_timestamp <= c.conversion_timestamp

        and t.event_timestamp >= timestamp_sub(
            c.conversion_timestamp,
            interval {{ var('attribution_window_days') }} day
        )

),

with_position as (

    select
        *,
        
        row_number() over (
            partition by conversion_id
            order by event_timestamp asc
        ) as touch_position,

        count(*) over (
            partition by conversion_id
        ) as path_length,

        row_number() over (
            partition by conversion_id
            order by event_timestamp desc
        ) as touch_position_from_end

    from joined

)

select
    conversion_id,
    user_id,
    conversion_timestamp,
    revenue,
    channel,
    channel_event_id,
    event_timestamp,
    campaign_id,
    hours_to_conversion,
    touch_position,
    path_length,

    case
        when touch_position = 1 then true
        else false
    end as is_first_touch,

    case
        when touch_position_from_end = 1 then true
        else false
    end as is_last_touch

from with_position