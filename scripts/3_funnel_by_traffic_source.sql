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
