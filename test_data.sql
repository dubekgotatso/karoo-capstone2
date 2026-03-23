-- test_data.sql

CREATE TABLE IF NOT EXISTS Suppliers (
    supplier_id INT PRIMARY KEY,
    name VARCHAR(100),
    cert_expiry_date DATE,
    status VARCHAR(50),
    last_audit DATE
);

CREATE TABLE IF NOT EXISTS Orders (
    order_id INT PRIMARY KEY,
    supplier_id INT REFERENCES Suppliers(supplier_id),
    order_date DATE,
    amount DECIMAL
);

CREATE TABLE IF NOT EXISTS Harvests (
    harvest_id INT PRIMARY KEY,
    supplier_id INT REFERENCES Suppliers(supplier_id),
    harvest_date DATE,
    yield_kg DECIMAL
);

-- Clear existing data if re-running
TRUNCATE TABLE Harvests, Orders, Suppliers CASCADE;

-- Insert dummy data
INSERT INTO Suppliers (supplier_id, name, cert_expiry_date, status) VALUES
(1, 'GoodFarm', CURRENT_DATE + INTERVAL '100 days', 'Active'),
(2, 'ExpiringFarm', CURRENT_DATE + INTERVAL '10 days', 'Active'),
(3, 'NoOrderFarm', CURRENT_DATE + INTERVAL '100 days', 'Active'),
(4, 'LowYieldFarm', CURRENT_DATE + INTERVAL '100 days', 'Active');

INSERT INTO Orders (order_id, supplier_id, order_date, amount) VALUES
(101, 1, CURRENT_DATE - INTERVAL '10 days', 500),
(102, 2, CURRENT_DATE - INTERVAL '20 days', 300),
(103, 4, CURRENT_DATE - INTERVAL '5 days', 200);
-- Supplier 3 has no orders

INSERT INTO Harvests (harvest_id, supplier_id, harvest_date, yield_kg) VALUES
(201, 1, CURRENT_DATE - INTERVAL '60 days', 100),
(202, 1, CURRENT_DATE - INTERVAL '30 days', 110),
(203, 1, CURRENT_DATE, 105),

(204, 2, CURRENT_DATE - INTERVAL '60 days', 80),
(205, 2, CURRENT_DATE - INTERVAL '30 days', 85),
(206, 2, CURRENT_DATE, 90),

(207, 3, CURRENT_DATE - INTERVAL '60 days', 200),
(208, 3, CURRENT_DATE - INTERVAL '30 days', 210),
(209, 3, CURRENT_DATE, 205),

(210, 4, CURRENT_DATE - INTERVAL '60 days', 100),
(211, 4, CURRENT_DATE - INTERVAL '30 days', 100),
(212, 4, CURRENT_DATE, 50); -- significant yield drop
