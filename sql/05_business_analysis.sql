-- ============================================================
-- BUSINESS ANALYSIS
-- ============================================================


-- 1. Overall AML Rate
SELECT
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN is_laundering THEN 1 ELSE 0 END)
        AS laundering_transactions,
    ROUND(
        100.0 * SUM(CASE WHEN is_laundering THEN 1 ELSE 0 END)
        / COUNT(*),
        4
    ) AS laundering_rate_percent
FROM core.transactions;


-- 2. AML Rate by Payment Format
SELECT
    payment_format,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN is_laundering THEN 1 ELSE 0 END)
        AS laundering_transactions,
    ROUND(
        100.0 * SUM(CASE WHEN is_laundering THEN 1 ELSE 0 END)
        / COUNT(*),
        4
    ) AS laundering_rate_percent
FROM core.transactions
GROUP BY payment_format
ORDER BY laundering_rate_percent DESC;


-- 3. Highest-Risk Originating Banks
SELECT
    from_bank,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN is_laundering THEN 1 ELSE 0 END)
        AS laundering_transactions,
    ROUND(
        100.0 * SUM(CASE WHEN is_laundering THEN 1 ELSE 0 END)
        / COUNT(*),
        4
    ) AS laundering_rate_percent
FROM core.transactions
GROUP BY from_bank
HAVING COUNT(*) >= 500
ORDER BY laundering_rate_percent DESC
LIMIT 20;


-- 4. AML Amount Exposure
SELECT
    SUM(amount_paid) AS total_transaction_amount,
    SUM(
        CASE
            WHEN is_laundering THEN amount_paid
            ELSE 0
        END
    ) AS laundering_amount,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN is_laundering THEN amount_paid
                ELSE 0
            END
        )
        / NULLIF(SUM(amount_paid), 0),
        4
    ) AS laundering_amount_percent
FROM core.transactions;

-- 5. Cross-Bank vs Same-Bank AML Risk
SELECT
    CASE
        WHEN from_bank <> to_bank THEN 'Cross-Bank'
        ELSE 'Same-Bank'
    END AS transaction_type,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN is_laundering THEN 1 ELSE 0 END)
        AS laundering_transactions,
    ROUND(
        100.0 * SUM(CASE WHEN is_laundering THEN 1 ELSE 0 END)
        / COUNT(*),
        4
    ) AS laundering_rate_percent
FROM core.transactions
GROUP BY transaction_type
ORDER BY laundering_rate_percent DESC;


-- 6. High-Risk Alerts by Rule
SELECT
    rule_name,
    COUNT(*) AS alert_count,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_alerts
FROM monitoring.alerts
GROUP BY rule_name
ORDER BY alert_count DESC;


-- 7. Highest-Risk Banks by Generated Alerts
SELECT
    from_bank,
    COUNT(*) AS high_risk_alerts
FROM monitoring.transaction_risk
WHERE risk_score >= 5
GROUP BY from_bank
ORDER BY high_risk_alerts DESC
LIMIT 20;

-- ============================================================
-- ADDITIONAL BUSINESS ANALYSIS
-- ============================================================


-- 5. Which payment formats contribute the most AML cases?
SELECT
    payment_format,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN is_laundering THEN 1 ELSE 0 END)
        AS laundering_transactions,
    ROUND(
        100.0 * SUM(CASE WHEN is_laundering THEN 1 ELSE 0 END)
        / NULLIF(
            SUM(SUM(CASE WHEN is_laundering THEN 1 ELSE 0 END))
            OVER (), 0
        ),
        2
    ) AS share_of_aml_percent
FROM core.transactions
GROUP BY payment_format
ORDER BY laundering_transactions DESC;


-- 6. Are high-value transactions disproportionately risky?
SELECT
    CASE
        WHEN amount_paid > 13524530.71 THEN 'High-Value'
        ELSE 'Normal-Value'
    END AS transaction_category,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN is_laundering THEN 1 ELSE 0 END)
        AS laundering_transactions,
    ROUND(
        100.0 * SUM(CASE WHEN is_laundering THEN 1 ELSE 0 END)
        / COUNT(*),
        4
    ) AS laundering_rate_percent
FROM core.transactions
GROUP BY transaction_category
ORDER BY laundering_rate_percent DESC;


-- 7. Which banks generate the most high-risk alerts?
SELECT
    from_bank,
    COUNT(*) AS high_risk_alerts
FROM monitoring.transaction_risk
WHERE risk_score >= 5
GROUP BY from_bank
ORDER BY high_risk_alerts DESC
LIMIT 20;


-- 8. What percentage of transactions are flagged as high-risk?
SELECT
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN risk_score >= 5 THEN 1 ELSE 0 END)
        AS high_risk_transactions,
    ROUND(
        100.0 * SUM(CASE WHEN risk_score >= 5 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS high_risk_percentage
FROM monitoring.transaction_risk;


-- 9. Which alert rules generate the most workload?
SELECT
    rule_name,
    COUNT(*) AS alert_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS share_of_alerts_percent
FROM monitoring.alerts
GROUP BY rule_name
ORDER BY alert_count DESC;


-- 10. Which entities show unusually high activity?
SELECT
    entity_id,
    entity_name,
    transaction_count,
    total_amount
FROM monitoring.entity_alerts
ORDER BY transaction_count DESC
LIMIT 20;


-- 11. How effectively do our rules capture known AML transactions?
SELECT
    COUNT(*) AS known_aml_transactions,
    SUM(
        CASE WHEN r.risk_score >= 5 THEN 1 ELSE 0 END
    ) AS aml_transactions_flagged,
    ROUND(
        100.0 *
        SUM(
            CASE WHEN r.risk_score >= 5 THEN 1 ELSE 0 END
        )
        / NULLIF(COUNT(*), 0),
        2
    ) AS detection_coverage_percent
FROM monitoring.transaction_risk r
JOIN core.transactions t
    ON r.transaction_id = t.transaction_id
WHERE t.is_laundering = TRUE;


-- 12. Which payment format + bank combinations have elevated AML rates?
SELECT
    payment_format,
    from_bank,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN is_laundering THEN 1 ELSE 0 END)
        AS laundering_transactions,
    ROUND(
        100.0 * SUM(CASE WHEN is_laundering THEN 1 ELSE 0 END)
        / COUNT(*),
        4
    ) AS laundering_rate_percent
FROM core.transactions
GROUP BY payment_format, from_bank
HAVING COUNT(*) >= 500
ORDER BY laundering_rate_percent DESC
LIMIT 20;


-- 13. How concentrated are AML cases among the top 10 banks?
WITH bank_aml AS (
    SELECT
        from_bank,
        SUM(CASE WHEN is_laundering THEN 1 ELSE 0 END)
            AS laundering_transactions
    FROM core.transactions
    GROUP BY from_bank
),
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            ORDER BY laundering_transactions DESC
        ) AS bank_rank
    FROM bank_aml
)
SELECT
    SUM(
        CASE
            WHEN bank_rank <= 10
            THEN laundering_transactions
            ELSE 0
        END
    ) AS top_10_aml_transactions,

    SUM(laundering_transactions) AS total_aml_transactions,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN bank_rank <= 10
                THEN laundering_transactions
                ELSE 0
            END
        )
        / NULLIF(SUM(laundering_transactions), 0),
        2
    ) AS top_10_aml_share_percent
FROM ranked;
SELECT
    rule_name,
    COUNT(*) AS alert_count
FROM monitoring.alerts
GROUP BY rule_name
ORDER BY alert_count DESC;