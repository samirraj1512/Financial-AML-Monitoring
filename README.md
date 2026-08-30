# Financial AML Monitoring & Risk Analytics

A SQL-driven **Anti-Money Laundering (AML) surveillance system** that transforms **5M+ financial transactions** into risk-scored alerts and account-level risk insights, with an interactive Power BI dashboard for monitoring and investigation.

## Project Overview

Built on **5M+ financial transactions**, the system identifies potentially suspicious activity using multiple transaction-level risk indicators and converts them into actionable alerts.

### Detection Architecture

Transactions  
→ Risk Indicators  
→ Weighted Risk Score  
→ Risk Classification  
→ Transaction Alerts  
→ Account-Level Monitoring  
→ Power BI Dashboard

## Risk Detection

The monitoring engine evaluates:

- **ACH transactions**
- **High-risk bank activity**
- **High-value transactions**
- **Cross-bank transfers**
- **High-activity accounts**

These indicators are combined into a **weighted risk score**, classified as:

`LOW → MEDIUM → HIGH → CRITICAL`

Alerts capture the **specific combination of indicators** that triggered the risk score, improving interpretability for analysts.

##  SQL & Data Engineering

- PostgreSQL-based analytical pipeline
- Transaction-level risk feature engineering
- Conditional risk scoring using SQL
- Window functions for alert identification
- Account-level aggregation for entity monitoring
- Separate transaction and entity risk tables

### Core Outputs

- `monitoring.transaction_risk` — transaction-level risk features and scores
- `monitoring.alerts` — risk-based transaction alerts
- `monitoring.entity_alerts` — account-level activity monitoring

## Power BI Dashboard

The dashboard provides:

- Total and high-risk alert KPIs
- Critical-risk monitoring
- High-value transaction analysis
- Alert distribution by detection rule
- Risk-level analysis
- Interactive slicers
- Alert investigation table
- Account-level activity insights

 ## Executive Monitoring Dashboard
<img width="903" alt="AML Executive Dashboard" src="https://github.com/user-attachments/assets/a86fd5f6-7664-4eac-90cf-2e73a6d4b521" />

 ## Risk & Entity Analysis
<img width="915" alt="AML Risk Analysis" src="https://github.com/user-attachments/assets/6e34c429-1aa5-4203-8c8b-9e5d82d08ee8" />

 ## Alert Investigation
<img width="908" alt="AML Alert Investigation" src="https://github.com/user-attachments/assets/3dca1d22-c84d-466f-9527-1b4b78827117" />

## Tech Stack

**Database:** PostgreSQL  
**SQL:** CTEs, CASE statements, aggregations, window functions 
**BI:** Power BI  
**Automation:** Python, SQLAlchemy  
**Data:** 5M+ financial transactions

## Project Structure

```text
Financial-AML-Monitoring/
│
├── data/
├── database/
├── sql/
│   ├── 01_data_overview.sql
│   ├── 02_risk_scoring.sql
│   ├── 03_alert_generation.sql
│   ├── 04_entity_risk.sql
│   └── 05_business_analysis.sql
│
├── powerbi/
│   └── AML_Surveillance__Dashboard.pbix
│
└── README.md
