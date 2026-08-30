-- ============================================================
-- CHECK POSTGRESQL CONNECTION
-- ============================================================

SELECT
    current_database() AS database_name,
    current_schema() AS schema_name,
    inet_server_addr() AS server_address,
    inet_server_port() AS server_port;


-- ============================================================
-- CHECK CURRENT ALERT TABLE
-- ============================================================

SELECT
    COUNT(*) AS total_alerts,

    SUM(
        CASE
            WHEN rule_name = 'HIGH_RISK_ACH_BANK'
            THEN 1 ELSE 0
        END
    ) AS high_risk_ach_bank,

    SUM(
        CASE
            WHEN rule_name = 'HIGH_VALUE_TRANSACTION'
            THEN 1 ELSE 0
        END
    ) AS high_value_transaction

FROM monitoring.alerts;

SELECT
    rule_name,
    COUNT(*) AS alert_count
FROM monitoring.alerts
GROUP BY rule_name
ORDER BY alert_count DESC;