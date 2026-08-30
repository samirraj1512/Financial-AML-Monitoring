DROP TABLE IF EXISTS monitoring.alerts;

CREATE TABLE monitoring.alerts AS
SELECT
    ROW_NUMBER() OVER (ORDER BY transaction_id) AS alert_id,
    transaction_id,

    CASE
        WHEN high_risk_bank_flag = 1
            THEN 'HIGH_RISK_ACH_BANK'
        WHEN high_value_flag = 1
            THEN 'HIGH_VALUE_TRANSACTION'
        WHEN ach_flag = 1
            THEN 'ACH_TRANSACTION'
        ELSE 'CROSS_BANK_TRANSACTION'
    END AS rule_name,

    risk_score,

    CONCAT(
        'Risk score: ', risk_score,
        ', Risk level: ', risk_level
    ) AS alert_reason,

    CURRENT_TIMESTAMP AS created_at

FROM monitoring.transaction_risk

WHERE risk_score >= 5;

SELECT
    COUNT(*) AS total_alerts
FROM monitoring.alerts;