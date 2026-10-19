--revenue funnel analysis

DECLARE @end_ts   DATETIME2(3) = '2026-02-03 04:10:18.555';
DECLARE @start_ts DATETIME2(3) = DATEADD(DAY, -30, @end_ts);

WITH funnel_revenue AS (
SELECT
		
		COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS total_visitors,
		COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS total_buyers,
		SUM(CASE WHEN event_type = 'purchase' THEN amount END) AS total_revenue,
		COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS total_orders
	FROM user_data
	WHERE event_date >  @start_ts
	  AND event_date <= @end_ts

)
SELECT 
	total_visitors,
	total_buyers,
	total_revenue,
	total_orders,
	total_revenue / total_orders AS avg_order_value,
	total_revenue / total_buyers AS revenue_per_buyer,
	total_revenue / total_visitors AS revenue_per_visitor

FROM funnel_revenue
