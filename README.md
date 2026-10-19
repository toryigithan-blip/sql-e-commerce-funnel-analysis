# 🛒 E-commerce Funnel Analysis (SQL Server)

## 📌 Executive Summary

This project analyzes 30 days of user event data to find where the e-commerce funnel loses customers and which channels bring real buyers. Checkout works well, with 92% of users who enter payment info completing the purchase. The main gap is view to cart. Social media brings high traffic but converts poorly (14% view-to-cart), while email converts best (63% view-to-cart, 34% view-to-purchase). Average order value is about $107. The recommendation is to protect checkout, improve the product page experience, and move marketing spend toward email and retargeting.

## ❓ Business Questions

- Where in the funnel do we lose the most users?
- Which traffic sources bring buyers, not just visitors?
- How long does a typical purchase journey take?
- What is the revenue value of a visitor, buyer and order?

## 🗂️ Dataset

| Column | Description |
|---|---|
| `user_id` | Unique user identifier |
| `event_type` | `page_view`, `add_to_cart`, `checkout_start`, `payment_info`, `purchase` |
| `event_date` | Event timestamp |
| `traffic_source` | Acquisition channel (organic, social, email, etc.) |
| `amount` | Order value, populated on `purchase` events |

Analysis window: the last 30 days ending 2026-02-03 04:10:18 (latest event in the data).

## 🛠️ Tools

SQL Server, CTEs, conditional aggregation, `DATEDIFF`

## 🔍 Approach

| # | Analysis | Technique |
|---|---|---|
| 1 | Funnel stages | `COUNT(DISTINCT CASE WHEN ...)` per stage |
| 2 | Step-to-step conversion | Stage counts divided by the prior stage |
| 3 | Funnel by traffic source | Same logic grouped by `traffic_source` |
| 4 | Time to conversion | `MIN` timestamp per stage per user, average gaps in minutes |
| 5 | Revenue funnel | Revenue, orders and buyers per visitor |

Funnel: `page_view` > `add_to_cart` > `checkout_start` > `payment_info` > `purchase`

## 📊 Key Findings

**1. View to cart is the weakest step**
- Payment to purchase is 92%, so there is no technical issue in the payment flow.
- People view products but do not add them to cart. Some of this is expected browsing, but product display may also play a role.

**2. Social media brings volume, email brings buyers**
- Social media drives about 30% of traffic but has the lowest view-to-cart rate (14%).
- Email has fewer views but converts far better: 63% view-to-cart, 34% view-to-purchase.
- Social media traffic looks like a vanity metric, since high volume is not turning into purchases.

**3. Journey time shows no red flags**
- 700 converted users: ~11 min view to cart, ~13 min cart to purchase, ~24 min total.
- No extreme values, so no sign of bot traffic. Worth confirming with the business whether 24 min is expected.

**4. Average order value is ~$107**
- Compared with average CAC (for example $50), it shows how efficient paid marketing is.

## 💡 Recommendations

**1. UX & Website Optimization**
- **Don't touch the checkout flow:** conversion from Payment to Purchase is excellent (~92%). The technical payment flow is frictionless.
  - *Action:* Do not redesign the checkout page right now; you risk breaking something that is working perfectly.

**2. Marketing Strategy**
- **Stop over-investing in social for sales:** Social Media drives ~30% of our traffic (Volume) but has the lowest conversion rate (Efficiency). We are likely paying for "window shoppers."
  - *Action:* Shift budget away from "Traffic" objectives on social ads and focus on "Retargeting" or "Lead Gen" to capture emails instead.
- **Double down on email marketing:** Email is our highest converting channel (~34% conversion rate vs ~6% for Social).
  - *Action:* Implement an aggressive email capture popup for high-volume Social visitors. If we can get them onto our email list, our data proves they are far more likely to buy later.

**3. Financial & Revenue**
- **Audit ad spend against AOV:** Our Average Order Value is ~$107.
  - *Action:* Set a strict Customer Acquisition Cost (CAC) limit. If we are paying more than $30-$40 to acquire a customer via Social Media ads (which convert poorly), we are likely losing money on those specific transactions.

## ⚠️ Limitations and Next Steps

**Limitations**
- One 30-day window, no seasonality
- No CAC in the data, channel profitability is an assumption

**Next steps**
- Track funnel rates week by week, and compare user groups by arrival week
- Break the funnel down by device and product category (needs extra data)
- Validate CAC with the marketing team

## 📁 Repository Structure

```
funnel-analysis/
├── dataset/
│   └── user_events.csv
├── scripts/
│   ├── 1_sales_funnel_in_different_stages.sql
│   ├── 2_conversion_rates_through_funnel.sql
│   ├── 3_funnel_by_traffic_source.sql
│   ├── 4_time_spent_in_funnel_stages.sql
│   └── 5_revenue_funnel_analysis.sql
└── README.md
```
