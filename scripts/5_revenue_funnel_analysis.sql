SELECT DISTINCT event_type  FROM user_data
SELECT MAX(event_date) FROM user_data

SELECT * FROM user_data

-- define sales funnel and the different stages
DECLARE @end_ts   DATETIME2(3) = '2026-02-03 04:10:18.555';
DECLARE @start_ts DATETIME2(3) = DATEADD(DAY, -30, @end_ts);

WITH funnel_stages AS (
	SELECT
		COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS stage_1_views,
		COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS stage_2_cart,
		COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage_3_checkout,
		COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS stage_4_payment,
		COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS stage_5_purchase
	FROM user_data
	WHERE event_date >  @start_ts
	  AND event_date <= @end_ts
)

SELECT * FROM funnel_stages

-- conversion rates through the funnel

DECLARE @end_ts   DATETIME2(3) = '2026-02-03 04:10:18.555';
DECLARE @start_ts DATETIME2(3) = DATEADD(DAY, -30, @end_ts);

WITH funnel_stages AS (
	SELECT
		COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS stage_1_views,
		COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS stage_2_cart,
		COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage_3_checkout,
		COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS stage_4_payment,
		COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS stage_5_purchase
	FROM user_data
	WHERE event_date >  @start_ts
	  AND event_date <= @end_ts
)

SELECT
	stage_1_views,
	stage_2_cart,
	ROUND(CAST(stage_2_cart AS float) * 100 / stage_1_views,2) AS view_to_cart_rate,
	stage_3_checkout,
	ROUND(CAST(stage_3_checkout AS float) * 100 / stage_2_cart,2) AS cart_to_checkout_rate,
	stage_4_payment,
	ROUND(CAST(stage_4_payment AS float) * 100 / stage_3_checkout,2) AS checkout_to_payment_rate,
	stage_5_purchase,
	ROUND(CAST(stage_5_purchase AS float) * 100 / stage_4_payment,2) AS payment_to_purchase_rate,
	ROUND(CAST(stage_5_purchase AS float) * 100 / stage_1_views,2) AS overall_conversion

FROM  funnel_stages

-- funnel by source, exploring different marketing channels


DECLARE @end_ts   DATETIME2(3) = '2026-02-03 04:10:18.555';
DECLARE @start_ts DATETIME2(3) = DATEADD(DAY, -30, @end_ts);

WITH source_funnel AS (
	SELECT
		traffic_source,
		COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS views,
		COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS carts,
		COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchases
	FROM user_data
	WHERE event_date >  @start_ts
	  AND event_date <= @end_ts
	GROUP BY traffic_source
)
SELECT 
	traffic_source,
	views,
	carts,
	purchases,
	ROUND(carts * 100 / views,2) AS cart_conversion_rate,
	ROUND(purchases * 100 / views,2) AS purchase_conversion_rate,
	ROUND(purchases * 100 / carts,2) AS cart__to_purchase_conversion_rate
FROM source_funnel
ORDER BY purchases DESC

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
