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

SQL Server (T-SQL), CTEs, conditional aggregation, `DATEDIFF`

## 🔍 Approach

| # | Analysis | Technique |
|---|---|---|
| 1 | Funnel stages | `COUNT(DISTINCT CASE WHEN ...)` per stage |
| 2 | Step-to-step conversion | Stage counts divided by the prior stage |
| 3 | Funnel by traffic source | Same logic grouped by `traffic_source` |
| 4 | Time to conversion | `MIN` timestamp per stage per user, average gaps in minutes |
| 5 | Revenue funnel | Revenue, orders and buyers per visitor |

Funnel: `page_view` > `add_to_cart` > `checkout_start` > `payment_info` > `purchase`

Full queries: [`funnel_analysis.sql`](funnel_analysis.sql)

## 📊 Key Findings

**1. The biggest drop-off is view to cart, not checkout**
- Payment to purchase converts at 92%. Almost everyone who enters payment info completes the order, so there is no sign of a technical problem in the payment flow.
- The lowest rate in the funnel is view to cart. This is partly expected, since many visitors browse without intent to buy.
- The open question is whether the site experience can lift this rate. Product presentation may not be showing items in the best way.

**2. Social media drives volume, email drives purchases**
- Organic and social bring in most of the traffic.
- Social has the lowest view-to-cart rate at 14%, while email reaches 63% and converts 34% of its viewers into purchases.
- Social brings many visitors but few buyers, so its traffic numbers overstate its business value. Email brings fewer views, but the people who arrive are far more likely to buy.
- Because of this, social deserves less attention as a sales channel.

**3. Journey time looks realistic**
- Across 700 converted users, view to cart takes ~11 minutes, cart to purchase ~13 minutes, and the full journey ~24 minutes on average.
- There are no extreme values, either very long or very short, so there is no sign of bot traffic or tracking errors.
- Whether 24 minutes is acceptable is a business question. It is worth checking with the team if the journey could be made faster.

**4. Revenue per order is solid, but needs a cost benchmark**
- Average order value (AOV) is ~$107.
- This number only becomes meaningful next to customer acquisition cost (CAC). If CAC is around $50, paid marketing is performing well. A higher CAC would put that spend at risk.

## 💡 Recommendations

**1. Keep checkout as is, improve the product experience**
- Payment to purchase converts at 92%, so the checkout flow already works. Redesigning it now would risk breaking something that is performing well.
- UX effort should go to product pages and the path to cart, where the largest drop-off sits.

**2. Stop over-investing in social for sales**
- Social brings the most volume but the lowest conversion (14% view-to-cart), so budget is likely going to window shoppers.
- Move social budget from getting clicks to retargeting and collecting emails, so interested visitors are not lost.

**3. Double down on email**
- Email is the highest converting channel (34% view-to-purchase), so each visitor from it is worth far more than a social visitor.
- Add an email capture prompt for high-volume social visitors. Once on the list, they are far more likely to buy later.

**4. Set a CAC limit based on AOV**
- With AOV at ~$107, acquisition cost must stay well below that to be profitable.
- Set a strict CAC cap per channel. For social, which converts poorly, paying more than $30 to $40 per customer likely loses money on those sales.

## ⚠️ Limitations and Next Steps

**Limitations**
- Each stage counts users who did that action, without checking they did the earlier steps first
- One 30-day window, no seasonality
- No CAC in the data, channel profitability is an assumption

**Next steps**
- Track funnel rates week by week, and compare user groups by arrival week
- Break the funnel down by device and product category (needs extra data)
- Validate CAC with the marketing team

## 📁 Repository Structure

```
funnel-analysis/
├── funnel_analysis.sql
├── user_events.csv
└── README.md
```
