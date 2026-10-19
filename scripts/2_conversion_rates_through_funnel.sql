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