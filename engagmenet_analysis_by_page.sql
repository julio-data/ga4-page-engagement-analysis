-- Step 1: Aggregate sessions, users, events, engagement time, and scrolls per page
WITH main_query AS (
  SELECT
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') AS page_location,
    COUNT(DISTINCT CONCAT(user_pseudo_id, '-', (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id'))) AS sessions,
    COUNT(DISTINCT user_pseudo_id) AS unique_users,
    COUNT(*) AS total_events,
    SUM((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'engagement_time_msec')) AS session_time,
    COUNTIF(event_name = 'scroll') AS scroll_90
  FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
  GROUP BY page_location
),

-- Step 2: Identify engaged pages based on total events and total engagement time
cte_engagement AS (
  SELECT
    page_location,
    sessions,
    unique_users,
    total_events,
    session_time,
    scroll_90,
    IF(total_events >= 2 AND session_time > 10000, sessions, NULL) AS session_with_interaction
  FROM main_query
),

-- Step 3: Calculate average metrics and interaction ratios per page
engagement_calculations AS (
  SELECT
    page_location,
    sessions,
    unique_users,
    total_events,
    session_time,
    scroll_90,
    session_with_interaction,
    ROUND(SAFE_DIVIDE(total_events, sessions), 2) AS avg_events_per_session,
    ROUND(SAFE_DIVIDE(session_time, sessions) / 60000, 2) AS avg_session_duration_min,
    ROUND(SAFE_DIVIDE(session_with_interaction, sessions), 2) AS engagement_sessions,
    ROUND(SAFE_DIVIDE(scroll_90, sessions), 2) AS scroll_rate
  FROM cte_engagement
)

-- Step 4: Assign an engagement level to each page based on thresholds
SELECT
  *,
  CASE
    WHEN engagement_sessions > 0.8
         AND avg_session_duration_min >= 2
         AND avg_events_per_session >= 5
         AND scroll_rate >= 0.6 THEN 'High engagement'
    WHEN engagement_sessions BETWEEN 0.5 AND 0.8
         AND avg_session_duration_min >= 1
         AND scroll_rate >= 0.3 THEN 'Medium engagement'
    ELSE 'Low engagement'
  END AS engagement_level
FROM engagement_calculations
