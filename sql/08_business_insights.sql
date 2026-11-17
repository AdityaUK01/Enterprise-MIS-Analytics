
USE enterprise_mis;

-- =====================================================
-- 1. OVERALL EMPLOYEE SUMMARY
-- =====================================================

SELECT
    COUNT(*) AS TotalEmployees,
    COUNT(DISTINCT o.EmployeeID) AS ActiveEmployees,
    COUNT(o.OrderID) AS TotalOrders,
    ROUND(SUM(o.SalesAmount), 2) AS TotalSales,
    ROUND(SUM(o.SalesAmount - o.CostAmount), 2) AS TotalProfit
FROM Employees e
LEFT JOIN Orders o
    ON e.EmployeeID = o.EmployeeID;


-- =====================================================
-- 2. EMPLOYEE-WISE PERFORMANCE
-- =====================================================

SELECT
    e.EmployeeID,
    e.EmployeeName,
    e.Region,
    e.Department,
    COUNT(o.OrderID) AS TotalOrders,
    COALESCE(SUM(o.Quantity), 0) AS TotalQuantity,
    ROUND(COALESCE(SUM(o.SalesAmount), 0), 2) AS TotalSales,
    ROUND(
        COALESCE(SUM(o.SalesAmount - o.CostAmount), 0), 2
    ) AS TotalProfit
FROM Employees e
LEFT JOIN Orders o
    ON e.EmployeeID = o.EmployeeID
GROUP BY
    e.EmployeeID,
    e.EmployeeName,
    e.Region,
    e.Department
ORDER BY TotalSales DESC;


-- =====================================================
-- 3. TOP 10 EMPLOYEES BY SALES
-- =====================================================

SELECT
    e.EmployeeID,
    e.EmployeeName,
    e.Region,
    COUNT(o.OrderID) AS TotalOrders,
    ROUND(SUM(o.SalesAmount), 2) AS TotalSales
FROM Employees e
JOIN Orders o
    ON e.EmployeeID = o.EmployeeID
GROUP BY
    e.EmployeeID,
    e.EmployeeName,
    e.Region
ORDER BY TotalSales DESC
LIMIT 10;


-- =====================================================
-- 4. EMPLOYEE PROFITABILITY RANKING
-- =====================================================

SELECT
    e.EmployeeID,
    e.EmployeeName,
    ROUND(SUM(o.SalesAmount), 2) AS TotalSales,
    ROUND(SUM(o.SalesAmount - o.CostAmount), 2) AS TotalProfit,
    RANK() OVER (
        ORDER BY SUM(o.SalesAmount - o.CostAmount) DESC
    ) AS ProfitRank
FROM Employees e
JOIN Orders o
    ON e.EmployeeID = o.EmployeeID
GROUP BY
    e.EmployeeID,
    e.EmployeeName
ORDER BY ProfitRank;


-- =====================================================
-- 5. EMPLOYEE-WISE PROFIT MARGIN
-- =====================================================

SELECT
    e.EmployeeID,
    e.EmployeeName,
    ROUND(SUM(o.SalesAmount), 2) AS TotalSales,
    ROUND(SUM(o.SalesAmount - o.CostAmount), 2) AS TotalProfit,
    ROUND(
        SUM(o.SalesAmount - o.CostAmount) /
        NULLIF(SUM(o.SalesAmount), 0) * 100,
        2
    ) AS ProfitMargin
FROM Employees e
JOIN Orders o
    ON e.EmployeeID = o.EmployeeID
GROUP BY
    e.EmployeeID,
    e.EmployeeName
ORDER BY ProfitMargin DESC;


-- =====================================================
-- 6. REGION-WISE EMPLOYEE PERFORMANCE
-- =====================================================

SELECT
    e.Region,
    COUNT(DISTINCT e.EmployeeID) AS TotalEmployees,
    COUNT(o.OrderID) AS TotalOrders,
    ROUND(SUM(o.SalesAmount), 2) AS TotalSales,
    ROUND(SUM(o.SalesAmount - o.CostAmount), 2) AS TotalProfit
FROM Employees e
LEFT JOIN Orders o
    ON e.EmployeeID = o.EmployeeID
GROUP BY e.Region
ORDER BY TotalSales DESC;


-- =====================================================
-- 7. DEPARTMENT-WISE PERFORMANCE
-- =====================================================

SELECT
    e.Department,
    COUNT(DISTINCT e.EmployeeID) AS TotalEmployees,
    COUNT(o.OrderID) AS TotalOrders,
    ROUND(SUM(o.SalesAmount), 2) AS TotalSales,
    ROUND(SUM(o.SalesAmount - o.CostAmount), 2) AS TotalProfit
FROM Employees e
LEFT JOIN Orders o
    ON e.EmployeeID = o.EmployeeID
GROUP BY e.Department
ORDER BY TotalSales DESC;


-- =====================================================
-- 8. EMPLOYEE ORDER STATUS ANALYSIS
-- =====================================================

SELECT
    e.EmployeeName,
    o.OrderStatus,
    COUNT(o.OrderID) AS TotalOrders,
    ROUND(SUM(o.SalesAmount), 2) AS TotalSales
FROM Employees e
JOIN Orders o
    ON e.EmployeeID = o.EmployeeID
GROUP BY
    e.EmployeeID,
    e.EmployeeName,
    o.OrderStatus
ORDER BY e.EmployeeName, o.OrderStatus;


-- =====================================================
-- 9. MONTHLY EMPLOYEE SALES PERFORMANCE
-- =====================================================

SELECT
    DATE_FORMAT(o.OrderDate, '%Y-%m') AS SalesMonth,
    e.EmployeeName,
    COUNT(o.OrderID) AS TotalOrders,
    ROUND(SUM(o.SalesAmount), 2) AS MonthlySales,
    ROUND(SUM(o.SalesAmount - o.CostAmount), 2) AS MonthlyProfit
FROM Employees e
JOIN Orders o
    ON e.EmployeeID = o.EmployeeID
GROUP BY
    DATE_FORMAT(o.OrderDate, '%Y-%m'),
    e.EmployeeID,
    e.EmployeeName
ORDER BY SalesMonth, MonthlySales DESC;


-- =====================================================
-- 10. EMPLOYEE SALES CONTRIBUTION
-- =====================================================

SELECT
    e.EmployeeID,
    e.EmployeeName,
    ROUND(SUM(o.SalesAmount), 2) AS EmployeeSales,
    ROUND(
        SUM(o.SalesAmount) * 100.0 /
        NULLIF((SELECT SUM(SalesAmount) FROM Orders), 0),
        2
    ) AS SalesContributionPercentage
FROM Employees e
JOIN Orders o
    ON e.EmployeeID = o.EmployeeID
GROUP BY
    e.EmployeeID,
    e.EmployeeName
ORDER BY EmployeeSales DESC;
