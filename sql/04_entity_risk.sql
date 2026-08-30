DROP TABLE IF EXISTS monitoring.entity_alerts;

CREATE TABLE monitoring.entity_alerts AS
SELECT
    ROW_NUMBER() OVER (ORDER BY transaction_count DESC) AS entity_alert_id,
    entity_id,
    entity_name,
    transaction_count,
    total_amount,
    'HIGH_ENTITY_ACTIVITY' AS rule_name,
    6 AS risk_score,
    'Entity has unusually high transaction activity' AS alert_reason,
    CURRENT_TIMESTAMP AS created_at

FROM (
    SELECT
        e.entity_id,
        e.entity_name,
        COUNT(t.transaction_id) AS transaction_count,
        SUM(t.amount_paid) AS total_amount
    FROM core.entities e
    JOIN core.accounts a
        ON e.entity_id = a.entity_id
    JOIN core.transactions t
        ON a.account_number = t.from_account
    GROUP BY e.entity_id, e.entity_name
) x

WHERE transaction_count >= 500;

SELECT COUNT(*) AS entity_alerts
FROM monitoring.entity_alerts;