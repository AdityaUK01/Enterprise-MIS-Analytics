
USE enterprise_mis;

-- =====================================================
-- PROJECT 1: ENTERPRISE MIS ANALYTICS
-- FILE 10: BUSINESS INSIGHTS
-- =====================================================


-- 1. EXECUTIVE BUSINESS SUMMARY

SELECT
    COUNT(*) AS TotalOrders,
    SUM(CASE WHEN OrderStatus = 'Delivered' THEN 1 ELSE 0 END)
        AS DeliveredOrders,
    SUM(CASE WHEN OrderStatus = 'Returned' THEN 1 ELSE 0 END)
        AS ReturnedOrders,

    ROUND(SUM(SalesAmount), 2) AS RecordedSales,

    ROUND(SUM(
        CASE WHEN OrderStatus = 'Delivered'
        THEN SalesAmount ELSE 0 END
    ), 2) AS DeliveredSales,

    ROUND(SUM(
        CASE WHEN OrderStatus = 'Delivered'
        THEN SalesAmount - CostAmount ELSE 0 END
    ), 2) AS DeliveredGrossProfit,

    ROUND(
        SUM(CASE WHEN OrderStatus = 'Returned' THEN 1 ELSE 0 END)
        / COUNT(*) * 100, 2
    ) AS ReturnRatePercentage

FROM Orders;


-- 2. DELIVERED VS RETURNED SALES ANALYSIS

SELECT
    OrderStatus,
    COUNT(*) AS TotalOrders,
    ROUND(SUM(SalesAmount), 2) AS TotalSales,
    ROUND(SUM(SalesAmount - CostAmount), 2) AS GrossProfit,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Orders), 2
    ) AS OrderPercentage
FROM Orders
GROUP BY OrderStatus;


-- 3. MONTHLY DELIVERED SALES TREND

SELECT
    DATE_FORMAT(OrderDate, '%Y-%m') AS SalesMonth,
    COUNT(*) AS DeliveredOrders,
    ROUND(SUM(SalesAmount), 2) AS DeliveredSales,
    ROUND(SUM(SalesAmount - CostAmount), 2) AS GrossProfit
FROM Orders
WHERE OrderStatus = 'Delivered'
GROUP BY DATE_FORMAT(OrderDate, '%Y-%m')
ORDER BY SalesMonth;


-- 4. REGIONAL TARGET PERFORMANCE
-- Compare delivered sales against monthly targets.

WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(OrderDate, '%Y-%m') AS SalesMonth,
        c.Region,
        SUM(SalesAmount) AS ActualSales
    FROM Orders o
    JOIN Customers c
        ON o.CustomerID = c.CustomerID
    WHERE o.OrderStatus = 'Delivered'
    GROUP BY DATE_FORMAT(OrderDate, '%Y-%m'), c.Region
),

RegionalTargets AS (
    SELECT
        DATE_FORMAT(Month, '%Y-%m') AS TargetMonth,
        Region,
        SUM(SalesTarget) AS SalesTarget
    FROM Targets
    GROUP BY DATE_FORMAT(Month, '%Y-%m'), Region
)

SELECT
    t.Region,
    ROUND(SUM(t.SalesTarget), 2) AS TotalTarget,
    ROUND(SUM(COALESCE(m.ActualSales, 0)), 2) AS ActualSales,

    ROUND(
        SUM(COALESCE(m.ActualSales, 0)) - SUM(t.SalesTarget), 2
    ) AS TargetGap,

    ROUND(
        SUM(COALESCE(m.ActualSales, 0))
        / NULLIF(SUM(t.SalesTarget), 0) * 100, 2
    ) AS AchievementPercentage

FROM RegionalTargets t
LEFT JOIN MonthlySales m
    ON t.TargetMonth = m.SalesMonth
    AND t.Region = m.Region

GROUP BY t.Region
ORDER BY AchievementPercentage DESC;


-- 5. UNDERPERFORMING REGIONS

WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(o.OrderDate, '%Y-%m') AS SalesMonth,
        c.Region,
        SUM(o.SalesAmount) AS ActualSales
    FROM Orders o
    JOIN Customers c
        ON o.CustomerID = c.CustomerID
    WHERE o.OrderStatus = 'Delivered'
    GROUP BY DATE_FORMAT(o.OrderDate, '%Y-%m'), c.Region
),

MonthlyPerformance AS (
    SELECT
        t.Region,
        t.Month,
        t.SalesTarget,
        COALESCE(m.ActualSales, 0) AS ActualSales
    FROM Targets t
    LEFT JOIN MonthlySales m
        ON DATE_FORMAT(t.Month, '%Y-%m') = m.SalesMonth
        AND t.Region = m.Region
)

SELECT
    Region,
    COUNT(*) AS MonthsBelowTarget,
    ROUND(SUM(SalesTarget), 2) AS TotalTarget,
    ROUND(SUM(ActualSales), 2) AS ActualSales,
    ROUND(SUM(SalesTarget - ActualSales), 2) AS TotalShortfall
FROM MonthlyPerformance
WHERE ActualSales < SalesTarget
GROUP BY Region
ORDER BY TotalShortfall DESC;


-- 6. BEST AND WORST PRODUCT CATEGORIES

SELECT
    p.Category,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    SUM(o.Quantity) AS UnitsSold,
    ROUND(SUM(o.SalesAmount), 2) AS DeliveredSales,
    ROUND(SUM(o.SalesAmount - o.CostAmount), 2) AS GrossProfit,
    ROUND(
        SUM(o.SalesAmount - o.CostAmount)
        / NULLIF(SUM(o.SalesAmount), 0) * 100, 2
    ) AS ProfitMarginPercentage
FROM Orders o
JOIN Products p
    ON o.ProductID = p.ProductID
WHERE o.OrderStatus = 'Delivered'
GROUP BY p.Category
ORDER BY GrossProfit DESC;


-- 7. TOP 10 PRODUCTS BY DELIVERED SALES

SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    SUM(o.Quantity) AS UnitsSold,
    ROUND(SUM(o.SalesAmount), 2) AS DeliveredSales,
    ROUND(SUM(o.SalesAmount - o.CostAmount), 2) AS GrossProfit
FROM Orders o
JOIN Products p
    ON o.ProductID = p.ProductID
WHERE o.OrderStatus = 'Delivered'
GROUP BY p.ProductID, p.ProductName, p.Category
ORDER BY DeliveredSales DESC
LIMIT 10;


-- 8. TOP 10 CUSTOMERS BY DELIVERED REVENUE

SELECT
    c.CustomerID,
    c.CustomerName,
    c.Region,
    COUNT(DISTINCT o.OrderID) AS DeliveredOrders,
    ROUND(SUM(o.SalesAmount), 2) AS DeliveredRevenue,
    ROUND(SUM(o.SalesAmount - o.CostAmount), 2) AS GrossProfit
FROM Orders o
JOIN Customers c
    ON o.CustomerID = c.CustomerID
WHERE o.OrderStatus = 'Delivered'
GROUP BY c.CustomerID, c.CustomerName, c.Region
ORDER BY DeliveredRevenue DESC
LIMIT 10;


-- 9. EMPLOYEE PERFORMANCE INSIGHTS

SELECT
    e.EmployeeID,
    e.EmployeeName,
    e.Region,
    e.Department,
    COUNT(o.OrderID) AS DeliveredOrders,
    ROUND(SUM(o.SalesAmount), 2) AS DeliveredSales,
    ROUND(SUM(o.SalesAmount - o.CostAmount), 2) AS GrossProfit
FROM Employees e
LEFT JOIN Orders o
    ON e.EmployeeID = o.EmployeeID
    AND o.OrderStatus = 'Delivered'
GROUP BY
    e.EmployeeID,
    e.EmployeeName,
    e.Region,
    e.Department
ORDER BY DeliveredSales DESC;


-- 10. INVENTORY RISK AND PRODUCT DEMAND

SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    p.StockQty,
    p.ReorderLevel,
    COALESCE(SUM(
        CASE WHEN o.OrderStatus = 'Delivered'
        THEN o.Quantity ELSE 0 END
    ), 0) AS DeliveredUnitsSold,

    CASE
        WHEN p.StockQty <= p.ReorderLevel
            THEN 'Reorder Required'
        WHEN p.StockQty <= p.ReorderLevel * 1.5
            THEN 'Low Stock Warning'
        ELSE 'Stock Available'
    END AS InventoryStatus

FROM Products p
LEFT JOIN Orders o
    ON p.ProductID = o.ProductID
GROUP BY
    p.ProductID,
    p.ProductName,
    p.Category,
    p.StockQty,
    p.ReorderLevel
ORDER BY
    CASE
        WHEN p.StockQty <= p.ReorderLevel THEN 1
        WHEN p.StockQty <= p.ReorderLevel * 1.5 THEN 2
        ELSE 3
    END,
    DeliveredUnitsSold DESC;


-- =====================================================
-- END OF FILE 10
-- =====================================================
