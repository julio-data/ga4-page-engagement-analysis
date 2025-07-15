# GA4 Page Engagement Analysis

Behavioral analysis of web pages using GA4 data in BigQuery. Includes scroll, session duration, engagement rate, and more.

This repository contains a SQL query for analyzing user behavior on individual web pages using GA4 data exported to BigQuery.

The query calculates behavioral metrics per `page_location`, helping you understand how users interact with specific pages.

## 📊 Metrics included:

- **Sessions**: Total sessions where the page was loaded
- **Unique users**: Number of distinct users per page
- **Total events**: All events triggered on the page
- **Session time**: Total engagement time in milliseconds
- **Average events per session**
- **Average session duration (in minutes)**
- **Engagement sessions rate**: % of sessions with interaction (≥ 2 events and >10s engagement)
- **Scroll rate**: % of sessions where the `scroll` event occurred (proxy for deep scroll)
- **Engagement level**: Page quality classification (`High`, `Medium`, or `Low`) based on combined metrics

## 🧠 Use case

This analysis helps content teams, marketers, and UX designers:

- Identify high-performing pages
- Detect low-engagement or high-bounce pages
- Prioritize areas for content optimization or layout changes

✅ 100% SQL  
📊 Based on: `bigquery-public-data.ga4_obfuscated_sample_ecommerce`
