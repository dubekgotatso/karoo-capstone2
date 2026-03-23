CREATE OR REPLACE VIEW v_supplier_health AS
WITH SupplierHarvests AS (
    SELECT 
        supplier_id,
        harvest_date,
        yield_kg,
        AVG(yield_kg) OVER (
            PARTITION BY supplier_id 
            ORDER BY harvest_date 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_avg_yield,
        ROW_NUMBER() OVER(PARTITION BY supplier_id ORDER BY harvest_date DESC) as rn
    FROM Harvests
),
LatestHarvests AS (
    SELECT supplier_id, yield_kg AS latest_yield, rolling_avg_yield
    FROM SupplierHarvests
    WHERE rn = 1
),
SupplierOrders AS (
    SELECT 
        supplier_id,
        COUNT(order_id) FILTER (WHERE order_date >= CURRENT_DATE - INTERVAL '90 days') AS orders_90d
    FROM Orders
    GROUP BY supplier_id
)
SELECT 
    s.supplier_id,
    s.status,
    CASE 
        WHEN s.cert_expiry_date IS NULL THEN 'Unknown'
        WHEN s.cert_expiry_date < CURRENT_DATE THEN 'Expired'
        WHEN s.cert_expiry_date <= CURRENT_DATE + INTERVAL '30 days' THEN 'Expiring Soon'
        ELSE 'Valid'
    END AS cert_status,
    COALESCE(so.orders_90d, 0) AS orders_90d,
    lh.latest_yield,
    lh.rolling_avg_yield
FROM Suppliers s
LEFT JOIN LatestHarvests lh ON s.supplier_id = lh.supplier_id
LEFT JOIN SupplierOrders so ON s.supplier_id = so.supplier_id;

-- Risk-Flagging Query
-- Uncomment to test directly in SQL:
-- SELECT supplier_id
-- FROM v_supplier_health
-- WHERE cert_status IN ('Expired', 'Expiring Soon')
--    OR orders_90d = 0
--    OR latest_yield < (0.8 * rolling_avg_yield);
