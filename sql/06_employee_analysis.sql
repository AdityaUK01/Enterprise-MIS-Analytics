
USE enterprise_mis;

-- =====================================================
-- 1. OVERALL CUSTOMER SUMMARY
-- =====================================================

SELECT
    COUNT(DISTINCT c.CustomerID) AS TotalCustomers,
    COUNT(DISTINCT o.CustomerID) AS PurchasingCustomers,
    COUNT(o.OrderID) AS TotalOrders,
    ROUND(SUM(o.SalesAmount), 2) AS TotalSales,
    ROUND(AVG(o.SalesAmount), 2) AS AverageOrderValue
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID;


-- =====================================================
-- 2. TOP 10 CUSTOMERS BY SALES
-- =====================================================

SELECT
    c.CustomerID,
    c.CustomerName,
    c.City,
    c.Region,
    COUNT(o.OrderID) AS TotalOrders,
    ROUND(SUM(o.SalesAmount), 2) AS TotalSales,
    ROUND(SUM(o.SalesAmount - o.CostAmount), 2) AS TotalProfit
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY
    c.CustomerID,
    c.CustomerName,
    c.City,
    c.Region
ORDER BY TotalSales DESC
LIMIT 10;


-- =====================================================
-- 3. CUSTOMER PURCHASE FREQUENCY
-- =====================================================

SELECT
    c.CustomerID,
    c.CustomerName,
    COUNT(o.OrderID) AS TotalOrders,
    ROUND(SUM(o.SalesAmount), 2) AS TotalSales,
    CASE
        WHEN COUNT(o.OrderID) = 1 THEN 'One-time Customer'
        WHEN COUNT(o.OrderID) BETWEEN 2 AND 5 THEN 'Regular Customer'
        ELSE 'Frequent Customer'
    END AS CustomerType
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY
    c.CustomerID,
    c.CustomerName
ORDER BY TotalOrders DESC;


-- =====================================================
-- 4. REPEAT VS ONE-TIME CUSTOMERS
-- =====================================================

SELECT
    CustomerType,
    COUNT(*) AS CustomerCount,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM Customers), 2
    ) AS CustomerPercentage
FROM (
    SELECT
        c.CustomerID,
        CASE
            WHEN COUNT(o.OrderID) = 0 THEN 'No Purchase'
            WHEN COUNT(o.OrderID) = 1 THEN 'One-time Customer'
            ELSE 'Repeat Customer'
        END AS CustomerType
    FROM Customers c
    LEFT JOIN Orders o
        ON c.CustomerID = o.CustomerID
    GROUP BY c.CustomerID
) AS CustomerSummary
GROUP BY CustomerType
ORDER BY CustomerCount DESC;


-- =====================================================
-- 5. CITY-WISE CUSTOMER PERFORMANCE
-- =====================================================

SELECT
    c.City,
    COUNT(DISTINCT c.CustomerID) AS TotalCustomers,
    COUNT(o.OrderID) AS TotalOrders,
    ROUND(SUM(o.SalesAmount), 2) AS TotalSales,
    ROUND(SUM(o.SalesAmount - o.CostAmount), 2) AS TotalProfit
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY c.City
ORDER BY TotalSales DESC;


-- =====================================================
-- 6. REGION-WISE CUSTOMER CONTRIBUTION
-- =====================================================

SELECT
    c.Region,
    COUNT(DISTINCT c.CustomerID) AS TotalCustomers,
    COUNT(o.OrderID) AS TotalOrders,
    ROUND(SUM(o.SalesAmount), 2) AS TotalSales,
    ROUND(
        SUM(o.SalesAmount) /
        NULLIF(COUNT(DISTINCT c.CustomerID), 0), 2
    ) AS SalesPerCustomer
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY c.Region
ORDER BY TotalSales DESC;


-- =====================================================
-- 7. CUSTOMER PROFITABILITY RANKING
-- =====================================================

SELECT
    c.CustomerID,
    c.CustomerName,
    COUNT(o.OrderID) AS TotalOrders,
    ROUND(SUM(o.SalesAmount), 2) AS TotalSales,
    ROUND(SUM(o.SalesAmount - o.CostAmount), 2) AS TotalProfit,
    RANK() OVER (
        ORDER BY SUM(o.SalesAmount - o.CostAmount) DESC
    ) AS ProfitRank
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY
    c.CustomerID,
    c.CustomerName
ORDER BY ProfitRank;


-- =====================================================
-- 8. CUSTOMER SIGNUP ANALYSIS BY MONTH
-- =====================================================

SELECT
    DATE_FORMAT(SignupDate, '%Y-%m') AS SignupMonth,
    COUNT(*) AS NewCustomers
FROM Customers
GROUP BY DATE_FORMAT(SignupDate, '%Y-%m')
ORDER BY SignupMonth;


-- =====================================================
-- 9. CUSTOMERS WHO HAVE NEVER PURCHASED
-- =====================================================

SELECT
    c.CustomerID,
    c.CustomerName,
    c.City,
    c.Region,
    c.SignupDate
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL
ORDER BY c.SignupDate;


-- =====================================================
-- 10. CUSTOMER SALES CONTRIBUTION PERCENTAGE
-- =====================================================

SELECT
    c.CustomerID,
    c.CustomerName,
    ROUND(SUM(o.SalesAmount), 2) AS CustomerSales,
    ROUND(
        SUM(o.SalesAmount) * 100.0 /
        NULLIF((SELECT SUM(SalesAmount) FROM Orders), 0),
        2
    ) AS SalesContributionPercentage
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY
    c.CustomerID,
    c.CustomerName
ORDER BY CustomerSales DESC;
