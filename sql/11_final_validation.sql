USE enterprise_mis;

-- 1. Verify all five tables
SHOW TABLES;

-- 2. Verify row counts
SELECT 'Customers' AS TableName, COUNT(*) AS TotalRows FROM Customers
UNION ALL
SELECT 'Employees', COUNT(*) FROM Employees
UNION ALL
SELECT 'Products', COUNT(*) FROM Products
UNION ALL
SELECT 'Targets', COUNT(*) FROM Targets
UNION ALL
SELECT 'Orders', COUNT(*) FROM Orders;

-- 3. Verify order dates
SELECT
    MIN(OrderDate) AS FirstOrderDate,
    MAX(OrderDate) AS LastOrderDate
FROM Orders;

-- 4. Verify order status distribution
SELECT
    OrderStatus,
    COUNT(*) AS TotalOrders
FROM Orders
GROUP BY OrderStatus;

-- 5. Verify overall financial metrics
SELECT
    COUNT(*) AS TotalOrders,
    ROUND(SUM(SalesAmount), 2) AS RecordedSales,
    ROUND(SUM(CostAmount), 2) AS RecordedCost,
    ROUND(SUM(SalesAmount - CostAmount), 2) AS RecordedGrossProfit
FROM Orders;

-- 6. Verify missing customer relationships
SELECT COUNT(*) AS MissingCustomers
FROM Orders o
LEFT JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

-- 7. Verify missing product relationships
SELECT COUNT(*) AS MissingProducts
FROM Orders o
LEFT JOIN Products p ON o.ProductID = p.ProductID
WHERE p.ProductID IS NULL;

-- 8. Verify missing employee relationships
SELECT COUNT(*) AS MissingEmployees
FROM Orders o
LEFT JOIN Employees e ON o.EmployeeID = e.EmployeeID
WHERE e.EmployeeID IS NULL;