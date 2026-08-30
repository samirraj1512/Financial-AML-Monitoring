SELECT COUNT(*) AS total_transactions
FROM core.transactions;

SELECT COUNT(*) AS total_accounts
FROM core.accounts;

SELECT COUNT(*) AS total_entities
FROM core.entities;

-- Transaction date range
SELECT
    MIN("timestamp") AS first_transaction,
    MAX("timestamp") AS last_transaction
FROM core.transactions;

-- Currency distribution
SELECT
    payment_currency,
    COUNT(*) AS transaction_count
FROM core.transactions
GROUP BY payment_currency
ORDER BY transaction_count DESC;

-- Payment format distribution
SELECT
    payment_format,
    COUNT(*) AS transaction_count
FROM core.transactions
GROUP BY payment_format
ORDER BY transaction_count DESC;

-- Historical laundering labels
SELECT
    is_laundering,
    COUNT(*) AS transaction_count
FROM core.transactions
GROUP BY is_laundering
ORDER BY is_laundering;

-- Check missing values in key transaction fields
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT("timestamp") AS missing_timestamp,
    COUNT(*) - COUNT(from_bank) AS missing_from_bank,
    COUNT(*) - COUNT(from_account) AS missing_from_account,
    COUNT(*) - COUNT(to_bank) AS missing_to_bank,
    COUNT(*) - COUNT(to_account) AS missing_to_account,
    COUNT(*) - COUNT(amount_paid) AS missing_amount_paid,
    COUNT(*) - COUNT(payment_currency) AS missing_payment_currency,
    COUNT(*) - COUNT(payment_format) AS missing_payment_format
FROM core.transactions;


-- Check duplicate transaction IDs
SELECT
    transaction_id,
    COUNT(*) AS duplicate_count
FROM core.transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- Check invalid / non-positive transaction amounts
SELECT
    COUNT(*) AS non_positive_amounts
FROM core.transactions
WHERE amount_paid <= 0;


-- Check laundering transactions with their amount
SELECT
    COUNT(*) AS laundering_transactions,
    SUM(amount_paid) AS laundering_amount
FROM core.transactions
WHERE is_laundering = TRUE;

-- Investigate non-positive transaction amounts
SELECT
    amount_paid,
    COUNT(*) AS transaction_count
FROM core.transactions
WHERE amount_paid <= 0
GROUP BY amount_paid
ORDER BY amount_paid;


-- Check whether non-positive amounts are associated with laundering
SELECT
    is_laundering,
    COUNT(*) AS transaction_count
FROM core.transactions
WHERE amount_paid <= 0
GROUP BY is_laundering
ORDER BY is_laundering;


-- Check payment formats for non-positive transactions
SELECT
    payment_format,
    COUNT(*) AS transaction_count
FROM core.transactions
WHERE amount_paid <= 0
GROUP BY payment_format
ORDER BY transaction_count DESC;
-- Overall transaction amount statistics
-- Overall transaction amount statistics
SELECT
    MIN(amount_paid) AS minimum_amount,
    MAX(amount_paid) AS maximum_amount,
    AVG(amount_paid) AS average_amount,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY amount_paid) AS median_amount
FROM core.transactions;

-- Transaction amount distribution by percentile
SELECT
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY amount_paid) AS p90,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY amount_paid) AS p95,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY amount_paid) AS p99,
    PERCENTILE_CONT(0.999) WITHIN GROUP (ORDER BY amount_paid) AS p999
FROM core.transactions;

-- High-value transaction rule
-- Threshold = 99th percentile of transaction amount

SELECT
    COUNT(*) AS high_value_transactions,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM core.transactions),
        2
    ) AS percentage_of_transactions
FROM core.transactions
WHERE amount_paid > 13524530.7056;

-- Cash transaction amount distribution
SELECT
    COUNT(*) AS cash_transactions,
    MIN(amount_paid) AS minimum_cash_amount,
    MAX(amount_paid) AS maximum_cash_amount,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY amount_paid) AS p95_cash_amount
FROM core.transactions
WHERE payment_format = 'Cash';

-- Large cash transaction rule
-- Threshold = 95th percentile of cash transaction amount

SELECT
    COUNT(*) AS large_cash_transactions,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*)
         FROM core.transactions
         WHERE payment_format = 'Cash'),
        2
    ) AS percentage_of_cash_transactions
FROM core.transactions
WHERE payment_format = 'Cash'
  AND amount_paid > 1650074.28;

  -- Cross-bank transaction analysis

SELECT
    COUNT(*) AS cross_bank_transactions,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM core.transactions),
        2
    ) AS percentage_of_transactions
FROM core.transactions
WHERE from_bank <> to_bank;

-- Entity transaction activity
SELECT
    a.entity_id,
    e.entity_name,
    COUNT(*) AS transaction_count,
    SUM(t.amount_paid) AS total_amount
FROM core.transactions t
JOIN core.accounts a
    ON t.from_bank = a.bank_id
   AND t.from_account = a.account_number
JOIN core.entities e
    ON a.entity_id = e.entity_id
GROUP BY a.entity_id, e.entity_name
ORDER BY transaction_count DESC
LIMIT 20;

SELECT *
FROM core.accounts
LIMIT 10;
SELECT
    from_bank,
    from_account
FROM core.transactions
LIMIT 10;

SELECT *
FROM core.accounts
LIMIT 10;

-- Check account-number matches
SELECT COUNT(*) AS matching_accounts
FROM core.transactions t
JOIN core.accounts a
    ON t.from_account = a.account_number;

    -- Check bank + account matches
SELECT COUNT(*) AS matching_bank_accounts
FROM core.transactions t
JOIN core.accounts a
    ON t.from_bank = a.bank_id
   AND t.from_account = a.account_number;

   -- Check bank + account matches after removing leading zeros
SELECT COUNT(*) AS matching_normalized_accounts
FROM core.transactions t
JOIN core.accounts a
    ON LTRIM(t.from_bank, '0') = LTRIM(a.bank_id, '0')
   AND t.from_account = a.account_number;

   -- Transactions whose sender account cannot be mapped to an entity
SELECT
    COUNT(*) AS unmatched_transactions
FROM core.transactions t
LEFT JOIN core.accounts a
    ON LTRIM(t.from_bank, '0') = LTRIM(a.bank_id, '0')
   AND t.from_account = a.account_number
WHERE a.account_number IS NULL;

-- Inspect unmatched sender accounts
SELECT
    t.from_bank,
    t.from_account,
    COUNT(*) AS transaction_count
FROM core.transactions t
LEFT JOIN core.accounts a
    ON LTRIM(t.from_bank, '0') = LTRIM(a.bank_id, '0')
   AND t.from_account = a.account_number
WHERE a.account_number IS NULL
GROUP BY t.from_bank, t.from_account
ORDER BY transaction_count DESC;

SELECT
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT t.transaction_id) AS distinct_transactions,
    COUNT(DISTINCT CASE
        WHEN a.account_number IS NOT NULL
        THEN t.transaction_id
    END) AS matched_transactions,
    COUNT(DISTINCT CASE
        WHEN a.account_number IS NULL
        THEN t.transaction_id
    END) AS unmatched_transactions
FROM core.transactions t
LEFT JOIN core.accounts a
    ON LTRIM(t.from_bank, '0') = LTRIM(a.bank_id, '0')
   AND t.from_account = a.account_number;

   SELECT
    LTRIM(bank_id, '0') AS normalized_bank_id,
    account_number,
    COUNT(*) AS mapping_count
FROM core.accounts
GROUP BY
    LTRIM(bank_id, '0'),
    account_number
HAVING COUNT(*) > 1
ORDER BY mapping_count DESC;
-- Entity transaction activity

SELECT
    a.entity_id,
    e.entity_name,
    COUNT(DISTINCT t.transaction_id) AS transaction_count,
    SUM(t.amount_paid) AS total_amount
FROM core.transactions t
JOIN core.accounts a
    ON LTRIM(t.from_bank, '0') = LTRIM(a.bank_id, '0')
   AND t.from_account = a.account_number
JOIN core.entities e
    ON a.entity_id = e.entity_id
GROUP BY
    a.entity_id,
    e.entity_name
ORDER BY transaction_count DESC
LIMIT 20;

-- Entity transaction activity distribution

WITH entity_activity AS (
    SELECT
        a.entity_id,
        COUNT(DISTINCT t.transaction_id) AS transaction_count
    FROM core.transactions t
    JOIN core.accounts a
        ON LTRIM(t.from_bank, '0') = LTRIM(a.bank_id, '0')
       AND t.from_account = a.account_number
    GROUP BY a.entity_id
)
SELECT
    COUNT(*) AS total_entities,
    MIN(transaction_count) AS minimum_transactions,
    MAX(transaction_count) AS maximum_transactions,
    AVG(transaction_count) AS average_transactions,
    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY transaction_count) AS median_transactions,
    PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY transaction_count) AS p90_transactions,
    PERCENTILE_CONT(0.95)
        WITHIN GROUP (ORDER BY transaction_count) AS p95_transactions,
    PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY transaction_count) AS p99_transactions
FROM entity_activity;

-- High entity activity rule
-- Threshold = 99th percentile of entity transaction count

WITH entity_activity AS (
    SELECT
        a.entity_id,
        COUNT(DISTINCT t.transaction_id) AS transaction_count
    FROM core.transactions t
    JOIN core.accounts a
        ON LTRIM(t.from_bank, '0') = LTRIM(a.bank_id, '0')
       AND t.from_account = a.account_number
    GROUP BY a.entity_id
)
SELECT
    COUNT(*) AS high_activity_entities,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM entity_activity),
        2
    ) AS percentage_of_entities
FROM entity_activity
WHERE transaction_count > 158;

SELECT
    COUNT(*) AS total_transactions,

    SUM(CASE
        WHEN amount_paid > 13524530.7056 THEN 1
        ELSE 0
    END) AS high_value,

    SUM(CASE
        WHEN payment_format = 'Cash'
         AND amount_paid > 1650074.28 THEN 1
        ELSE 0
    END) AS large_cash,

    SUM(CASE
        WHEN from_bank <> to_bank THEN 1
        ELSE 0
    END) AS cross_bank

FROM core.transactions;

WITH entity_activity AS (
    SELECT
        a.entity_id,
        COUNT(DISTINCT t.transaction_id) AS transaction_count
    FROM core.transactions t
    JOIN core.accounts a
        ON LTRIM(t.from_bank, '0') = LTRIM(a.bank_id, '0')
       AND t.from_account = a.account_number
    GROUP BY a.entity_id
)
SELECT
    COUNT(*) AS high_activity_transactions
FROM core.transactions t
JOIN core.accounts a
    ON LTRIM(t.from_bank, '0') = LTRIM(a.bank_id, '0')
   AND t.from_account = a.account_number
JOIN entity_activity ea
    ON a.entity_id = ea.entity_id
WHERE ea.transaction_count > 158;

SELECT
    is_laundering,
    COUNT(*) AS transaction_count,

    SUM(CASE
        WHEN amount_paid > 13524530.7056 THEN 1
        ELSE 0
    END) AS high_value,

    SUM(CASE
        WHEN payment_format = 'Cash'
         AND amount_paid > 1650074.28 THEN 1
        ELSE 0
    END) AS large_cash,

    SUM(CASE
        WHEN from_bank <> to_bank THEN 1
        ELSE 0
    END) AS cross_bank

FROM core.transactions
GROUP BY is_laundering
ORDER BY is_laundering;

WITH entity_activity AS (
    SELECT
        a.entity_id,
        COUNT(DISTINCT t.transaction_id) AS transaction_count
    FROM core.transactions t
    JOIN core.accounts a
        ON LTRIM(t.from_bank, '0') = LTRIM(a.bank_id, '0')
       AND t.from_account = a.account_number
    GROUP BY a.entity_id
),
transaction_flags AS (
    SELECT
        t.transaction_id,
        t.is_laundering,
        CASE
            WHEN ea.transaction_count > 158 THEN 1
            ELSE 0
        END AS high_entity_activity
    FROM core.transactions t
    JOIN core.accounts a
        ON LTRIM(t.from_bank, '0') = LTRIM(a.bank_id, '0')
       AND t.from_account = a.account_number
    JOIN entity_activity ea
        ON a.entity_id = ea.entity_id
)
SELECT
    is_laundering,
    COUNT(*) AS transaction_count,
    SUM(high_entity_activity) AS high_activity_transactions,
    ROUND(
        SUM(high_entity_activity) * 100.0 / COUNT(*),
        2
    ) AS high_activity_percentage
FROM transaction_flags
GROUP BY is_laundering
ORDER BY is_laundering;

SELECT
    is_laundering,

    COUNT(*) AS transaction_count,

    SUM(
        CASE
            WHEN amount_paid > 13524530.7056
             AND from_bank <> to_bank
            THEN 1 ELSE 0
        END
    ) AS high_value_cross_bank,

    SUM(
        CASE
            WHEN payment_format = 'Cash'
             AND amount_paid > 1650074.28
             AND from_bank <> to_bank
            THEN 1 ELSE 0
        END
    ) AS large_cash_cross_bank,

    SUM(
        CASE
            WHEN amount_paid > 13524530.7056
             AND payment_format = 'Cash'
            THEN 1 ELSE 0
        END
    ) AS high_value_cash

FROM core.transactions
GROUP BY is_laundering
ORDER BY is_laundering;

SELECT
    payment_format,
    is_laundering,
    COUNT(*) AS transaction_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY payment_format),
        2
    ) AS laundering_percentage
FROM core.transactions
GROUP BY
    payment_format,
    is_laundering
ORDER BY
    payment_format,
    is_laundering;

    SELECT
    from_bank,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN is_laundering = TRUE THEN 1 ELSE 0 END) AS laundering_transactions,
    ROUND(
        SUM(CASE WHEN is_laundering = TRUE THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        4
    ) AS laundering_rate_percent
FROM core.transactions
WHERE payment_format = 'ACH'
GROUP BY from_bank
HAVING COUNT(*) >= 100
ORDER BY laundering_rate_percent DESC
LIMIT 20;

SELECT
    from_bank,
    COUNT(*) AS total_ach_transactions,
    SUM(CASE WHEN is_laundering = TRUE THEN 1 ELSE 0 END) AS laundering_transactions,
    ROUND(
        SUM(CASE WHEN is_laundering = TRUE THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        4
    ) AS laundering_rate_percent
FROM core.transactions
WHERE payment_format = 'ACH'
GROUP BY from_bank
HAVING COUNT(*) >= 500
ORDER BY laundering_rate_percent DESC
LIMIT 20;

SELECT
    COUNT(*) AS total_ach_transactions,
    SUM(CASE WHEN is_laundering = TRUE THEN 1 ELSE 0 END)
        AS laundering_ach_transactions,
    ROUND(
        SUM(CASE WHEN is_laundering = TRUE THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        4
    ) AS overall_ach_laundering_rate
FROM core.transactions
WHERE payment_format = 'ACH';

WITH ach_baseline AS (
    SELECT
        SUM(CASE WHEN is_laundering = TRUE THEN 1 ELSE 0 END) * 1.0
        / COUNT(*) AS baseline_rate
    FROM core.transactions
    WHERE payment_format = 'ACH'
),
bank_rates AS (
    SELECT
        from_bank,
        COUNT(*) AS total_ach_transactions,
        SUM(CASE WHEN is_laundering = TRUE THEN 1 ELSE 0 END)
            AS laundering_transactions
    FROM core.transactions
    WHERE payment_format = 'ACH'
    GROUP BY from_bank
    HAVING COUNT(*) >= 500
)
SELECT
    b.from_bank,
    b.total_ach_transactions,
    b.laundering_transactions,
    ROUND(
        b.laundering_transactions * 100.0
        / b.total_ach_transactions,
        4
    ) AS bank_laundering_rate,
    ROUND(
        (b.laundering_transactions * 1.0 / b.total_ach_transactions)
        / a.baseline_rate,
        2
    ) AS risk_ratio
FROM bank_rates b
CROSS JOIN ach_baseline a
ORDER BY risk_ratio DESC
LIMIT 20;

WITH ach_baseline AS (
    SELECT
        SUM(CASE WHEN is_laundering = TRUE THEN 1 ELSE 0 END) * 1.0
        / COUNT(*) AS baseline_rate
    FROM core.transactions
    WHERE payment_format = 'ACH'
),
bank_rates AS (
    SELECT
        from_bank,
        COUNT(*) AS total_ach_transactions,
        SUM(CASE WHEN is_laundering = TRUE THEN 1 ELSE 0 END)
            AS laundering_transactions
    FROM core.transactions
    WHERE payment_format = 'ACH'
    GROUP BY from_bank
    HAVING COUNT(*) >= 500
)
SELECT
    b.from_bank,
    b.total_ach_transactions,
    b.laundering_transactions,
    ROUND(
        b.laundering_transactions * 100.0
        / b.total_ach_transactions,
        4
    ) AS bank_laundering_rate,
    ROUND(
        (b.laundering_transactions * 1.0 / b.total_ach_transactions)
        / a.baseline_rate,
        2
    ) AS risk_ratio
FROM bank_rates b
CROSS JOIN ach_baseline a
WHERE
    (b.laundering_transactions * 1.0 / b.total_ach_transactions)
    / a.baseline_rate >= 2
ORDER BY risk_ratio DESC;

SELECT
    is_laundering,

    COUNT(*) AS transaction_count,

    SUM(CASE
        WHEN payment_format = 'ACH' THEN 3
        ELSE 0
    END) AS ach_points,

    SUM(CASE
        WHEN amount_paid > 13524530.7056 THEN 2
        ELSE 0
    END) AS high_value_points,

    SUM(CASE
        WHEN from_bank <> to_bank THEN 1
        ELSE 0
    END) AS cross_bank_points

FROM core.transactions
GROUP BY is_laundering
ORDER BY is_laundering;

WITH scored_transactions AS (
    SELECT
        transaction_id,
        is_laundering,
        (
            CASE WHEN payment_format = 'ACH' THEN 3 ELSE 0 END
            +
            CASE WHEN amount_paid > 13524530.7056 THEN 2 ELSE 0 END
            +
            CASE WHEN from_bank <> to_bank THEN 1 ELSE 0 END
        ) AS primary_score
    FROM core.transactions
)
SELECT
    is_laundering,
    primary_score,
    COUNT(*) AS transaction_count
FROM scored_transactions
GROUP BY
    is_laundering,
    primary_score
ORDER BY
    primary_score,
    is_laundering;

    SELECT
    COUNT(*) AS total_ach_transactions,

    SUM(
        CASE
            WHEN from_bank IN (
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
        END
    ) AS high_risk_bank_transactions,

    SUM(
        CASE
            WHEN from_bank IN (
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
            AND is_laundering = TRUE
            THEN 1
            ELSE 0
        END
    ) AS laundering_from_high_risk_banks

FROM core.transactions
WHERE payment_format = 'ACH';