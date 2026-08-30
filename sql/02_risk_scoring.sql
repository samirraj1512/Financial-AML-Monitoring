DROP TABLE IF EXISTS monitoring.transaction_risk;

CREATE TABLE monitoring.transaction_risk AS

SELECT
    t.transaction_id,
    t.timestamp,
    t.from_bank,
    t.from_account,
    t.to_bank,
    t.to_account,
    t.amount_paid,
    t.payment_currency,
    t.payment_format,

    CASE
        WHEN t.payment_format = 'ACH' THEN 1
        ELSE 0
    END AS ach_flag,

    CASE
        WHEN t.payment_format = 'ACH'
        AND t.from_bank IN (
            '0223',
            '0222',
            '025075',
            '0119',
            '004726',
            '009679',
            '023691',
            '001267',
            '021745',
            '021611',
            '0020486',
            '004403',
            '018196',
            '0121',
            '023842',
            '021749',
            '013554',
            '0238845',
            '013862',
            '021174'
        )
        THEN 1
        ELSE 0
    END AS high_risk_bank_flag,

    CASE
        WHEN t.from_bank <> t.to_bank THEN 1
        ELSE 0
    END AS cross_bank_flag,

    CASE
        WHEN t.amount_paid > 13524530.71 THEN 1
        ELSE 0
    END AS high_value_flag,

    (
        CASE
            WHEN t.payment_format = 'ACH' THEN 3
            ELSE 0
        END
        +
        CASE
            WHEN t.payment_format = 'ACH'
            AND t.from_bank IN (
                '0223',
                '0222',
                '025075',
                '0119',
                '004726',
                '009679',
                '023691',
                '001267',
                '021745',
                '021611',
                '0020486',
                '004403',
                '018196',
                '0121',
                '023842',
                '021749',
                '013554',
                '0238845',
                '013862',
                '021174'
            )
            THEN 3
            ELSE 0
        END
        +
        CASE
            WHEN t.amount_paid > 13524530.71 THEN 2
            ELSE 0
        END
        +
        CASE
            WHEN t.from_bank <> t.to_bank THEN 1
            ELSE 0
        END
    ) AS risk_score,

    CASE
        WHEN (
            CASE WHEN t.payment_format = 'ACH' THEN 3 ELSE 0 END
            +
            CASE
                WHEN t.payment_format = 'ACH'
                AND t.from_bank IN (
                    '0223','0222','025075','0119','004726',
                    '009679','023691','001267','021745',
                    '021611','0020486','004403','018196',
                    '0121','023842','021749','013554',
                    '0238845','013862','021174'
                )
                THEN 3 ELSE 0
            END
            +
            CASE WHEN t.amount_paid > 13524530.71 THEN 2 ELSE 0 END
            +
            CASE WHEN t.from_bank <> t.to_bank THEN 1 ELSE 0 END
        ) >= 7
        THEN 'CRITICAL'

        WHEN (
            CASE WHEN t.payment_format = 'ACH' THEN 3 ELSE 0 END
            +
            CASE
                WHEN t.payment_format = 'ACH'
                AND t.from_bank IN (
                    '0223','0222','025075','0119','004726',
                    '009679','023691','001267','021745',
                    '021611','0020486','004403','018196',
                    '0121','023842','021749','013554',
                    '0238845','013862','021174'
                )
                THEN 3 ELSE 0
            END
            +
            CASE WHEN t.amount_paid > 13524530.71 THEN 2 ELSE 0 END
            +
            CASE WHEN t.from_bank <> t.to_bank THEN 1 ELSE 0 END
        ) >= 5
        THEN 'HIGH'

        WHEN (
            CASE WHEN t.payment_format = 'ACH' THEN 3 ELSE 0 END
            +
            CASE
                WHEN t.payment_format = 'ACH'
                AND t.from_bank IN (
                    '0223','0222','025075','0119','004726',
                    '009679','023691','001267','021745',
                    '021611','0020486','004403','018196',
                    '0121','023842','021749','013554',
                    '0238845','013862','021174'
                )
                THEN 3 ELSE 0
            END
            +
            CASE WHEN t.amount_paid > 13524530.71 THEN 2 ELSE 0 END
            +
            CASE WHEN t.from_bank <> t.to_bank THEN 1 ELSE 0 END
        ) >= 3
        THEN 'MEDIUM'

        ELSE 'LOW'
    END AS risk_level

FROM core.transactions AS t;

CREATE TABLE monitoring.transaction_risk AS
SELECT
    t.transaction_id,
    t.timestamp,
    t.from_bank,
    t.from_account,
    t.to_bank,
    t.to_account,
    t.amount_paid,
    t.payment_currency,
    t.payment_format,

    CASE
        WHEN t.payment_format = 'ACH' THEN 1
        ELSE 0
    END AS ach_flag,

    CASE
        WHEN t.payment_format = 'ACH'
        AND t.from_bank IN (
            '0223','0222','025075','0119','004726',
            '009679','023691','001267','021745',
            '021611','0020486','004403','018196',
            '0121','023842','021749','013554',
            '0238845','013862','021174'
        )
        THEN 1
        ELSE 0
    END AS high_risk_bank_flag,

    CASE
        WHEN t.from_bank <> t.to_bank THEN 1
        ELSE 0
    END AS cross_bank_flag,

    CASE
        WHEN t.amount_paid > 13524530.71 THEN 1
        ELSE 0
    END AS high_value_flag

FROM core.transactions t;

ALTER TABLE monitoring.transaction_risk
ADD COLUMN risk_score INTEGER;

UPDATE monitoring.transaction_risk
SET risk_score =
    ach_flag * 3
    + high_risk_bank_flag * 3
    + high_value_flag * 2
    + cross_bank_flag;

    SELECT
    risk_score,
    COUNT(*) AS transactions
FROM monitoring.transaction_risk
GROUP BY risk_score
ORDER BY risk_score;

ALTER TABLE monitoring.transaction_risk
ADD COLUMN risk_level VARCHAR(20);

UPDATE monitoring.transaction_risk
SET risk_level =
    CASE
        WHEN risk_score >= 7 THEN 'CRITICAL'
        WHEN risk_score >= 5 THEN 'HIGH'
        WHEN risk_score >= 3 THEN 'MEDIUM'
        ELSE 'LOW'
    END;

    SELECT
    risk_level,
    COUNT(*) AS transactions
FROM monitoring.transaction_risk
GROUP BY risk_level
ORDER BY
    CASE risk_level
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        ELSE 4
    END;