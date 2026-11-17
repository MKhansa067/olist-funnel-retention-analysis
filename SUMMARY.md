# Summary: Olist Funnel, Retention and Late Delivery Analysis

**Question:** where do orders leak, do customers return, and does delivery performance drive satisfaction?
**Data:** 99,441 Olist orders (2016-2018), analyzed with SQL (SQLite).

**What I found**
1. 97.0% of orders reach the customer. The biggest leak (1,637 orders) is between approval and carrier handover.
2. Retention is very low: 0.48% in month 1, 1.77% within 6 months.
3. Late delivery (6.8% of orders) cuts the average review from 4.29 to 2.27 and drives about one third of low reviews. It is concentrated in RJ, BA and ES (11-12% late vs 4.5% in SP).
4. No clear evidence that late delivery reduces repeat purchase (1.47% vs 1.79%, within noise).

**What I would do (RICE)**
1. Fix delivery-promise accuracy in RJ/BA/ES (A/B test): RICE 12,321
2. Post-delivery re-engagement for repeat purchase: RICE 4,750
3. Resolve orders stuck before carrier handover: RICE 273

**Caveats:** observational data; Impact/Confidence/Effort in RICE are estimates; hypotheses (stock-outs, Black Friday) are unverified.