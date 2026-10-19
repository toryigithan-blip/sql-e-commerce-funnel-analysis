-- time to conversion analysis ( time spent by people in all the funnel stages)

DECLARE @end_ts   DATETIME2(3) = '2026-02-03 04:10:18.555';
DECLARE @start_ts DATETIME2(3) = DATEADD(DAY, -30, @end_ts);

WITH user_journey AS(
	SELECT
		user_id,
		MIN(CASE WHEN event_type = 'page_view' THEN event_date END) AS view_time,
		MIN(CASE WHEN event_type = 'add_to_cart' THEN event_date END) AS cart_time,
		MIN(CASE WHEN event_type = 'purchase' THEN event_date END) AS purchase_time
	FROM user_data
	WHERE event_date >  @start_ts
	  AND event_date <= @end_ts
	GROUP BY user_id
	HAVING MIN(CASE WHEN event_type = 'purchase' THEN event_date END) IS NOT NULL
)

SELECT
    COUNT(*) AS converted_users,
    CAST(AVG(DATEDIFF(SECOND, view_time, cart_time)     / 60.0) AS DECIMAL(18,2)) AS avg_view_to_cart_minutes,
    CAST(AVG(DATEDIFF(SECOND, cart_time, purchase_time) / 60.0) AS DECIMAL(18,2)) AS avg_cart_to_purchase_minutes,
    CAST(AVG(DATEDIFF(SECOND, view_time, purchase_time) / 60.0) AS DECIMAL(18,2)) AS avg_total_journey_minutes
FROM user_journey;