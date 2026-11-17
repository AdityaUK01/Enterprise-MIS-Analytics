
USE enterprise_mis;

-- =====================================================
-- 1. MONTHLY REGIONAL TARGET VS ACTUAL SALES
-- =====================================================

WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(o.OrderDate, '%Y-%m-01') AS SalesMonth,
        c.Region,
        SUM(o.SalesAmount) AS ActualSales
    FROM Orders o
    JOIN Customers c
        ON o.CustomerID = c.CustomerID
    GROUP BY
        DATE_FORMAT(o.OrderDate, '%Y-%m-01'),
        c.Region
)

SELECT
    DATE_FORMAT(t.Month, '%Y-%m') AS SalesMonth,
    t.Region,
    t.SalesTarget,
    ROUND(COALESCE(m.ActualSales, 0), 2) AS ActualSales,
    ROUND(COALESCE(m.ActualSales, 0) - t.SalesTarget, 2)
        AS TargetDifference,
    ROUND(
        COALESCE(m.ActualSales, 0) /
        NULLIF(t.SalesTarget, 0) * 100, 2
    ) AS AchievementPercentage,
    CASE
        WHEN COALESCE(m.ActualSales, 0) >= t.SalesTarget
            THEN 'Target Achieved'
        ELSE 'Target Not Achieved'
    END AS TargetStatus
FROM Targets t
LEFT JOIN MonthlySales m
    ON t.Month = STR_TO_DATE(
        CONCAT(m.SalesMonth, '-01'), '%Y-%m-%d'
    )
    AND t.Region = m.Region
ORDER BY t.Month, t.Region;


-- =====================================================
-- 2. REGIONAL TARGET ACHIEVEMENT SUMMARY
-- =====================================================

WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(o.OrderDate, '%Y-%m-01') AS SalesMonth,
        c.Region,
        SUM(o.SalesAmount) AS ActualSales
    FROM Orders o
    JOIN Customers c
        ON o.CustomerID = c.CustomerID
    GROUP BY
        DATE_FORMAT(o.OrderDate, '%Y-%m-01'),
        c.Region
)

SELECT
    t.Region,
    ROUND(SUM(t.SalesTarget), 2) AS TotalTarget,
    ROUND(SUM(COALESCE(m.ActualSales, 0)), 2) AS TotalActualSales,
    ROUND(
        SUM(COALESCE(m.ActualSales, 0)) - SUM(t.SalesTarget), 2
    ) AS TotalDifference,
    ROUND(
        SUM(COALESCE(m.ActualSales, 0)) /
        NULLIF(SUM(t.SalesTarget), 0) * 100, 2
    ) AS AchievementPercentage
FROM Targets t
LEFT JOIN MonthlySales m
    ON t.Month = STR_TO_DATE(
        CONCAT(m.SalesMonth, '-01'), '%Y-%m-%d'
    )
    AND t.Region = m.Region
GROUP BY t.Region
ORDER BY AchievementPercentage DESC;


-- =====================================================
-- 3. MONTHLY OVERALL TARGET ACHIEVEMENT
-- =====================================================

WITH MonthlyActual AS (
    SELECT
        DATE_FORMAT(OrderDate, '%Y-%m-01') AS SalesMonth,
        SUM(SalesAmount) AS ActualSales
    FROM Orders
    GROUP BY DATE_FORMAT(OrderDate, '%Y-%m-01')
),
MonthlyTarget AS (
    SELECT
        DATE_FORMAT(Month, '%Y-%m-01') AS SalesMonth,
        SUM(SalesTarget) AS TotalTarget
    FROM Targets
    GROUP BY DATE_FORMAT(Month, '%Y-%m-01')
)

SELECT
    t.SalesMonth,
    ROUND(t.TotalTarget, 2) AS TotalTarget,
    ROUND(COALESCE(a.ActualSales, 0), 2) AS ActualSales,
    ROUND(
        COALESCE(a.ActualSales, 0) - t.TotalTarget, 2
    ) AS TargetDifference,
    ROUND(
        COALESCE(a.ActualSales, 0) /
        NULLIF(t.TotalTarget, 0) * 100, 2
    ) AS AchievementPercentage
FROM MonthlyTarget t
LEFT JOIN MonthlyActual a
    ON t.SalesMonth = a.SalesMonth
ORDER BY t.SalesMonth;


-- =====================================================
-- 4. BEST AND WORST PERFORMING REGIONS
-- =====================================================

WITH RegionalPerformance AS (
    SELECT
        t.Region,
        SUM(t.SalesTarget) AS TotalTarget,
        SUM(COALESCE(m.ActualSales, 0)) AS ActualSales
    FROM Targets t
    LEFT JOIN (
        SELECT
            DATE_FORMAT(o.OrderDate, '%Y-%m-01') AS SalesMonth,
            c.Region,
            SUM(o.SalesAmount) AS ActualSales
        FROM Orders o
        JOIN Customers c
            ON o.CustomerID = c.CustomerID
        GROUP BY
            DATE_FORMAT(o.OrderDate, '%Y-%m-01'),
            c.Region
    ) m
        ON t.Month = STR_TO_DATE(
            CONCAT(m.SalesMonth, '-01'), '%Y-%m-%d'
        )
        AND t.Region = m.Region
    GROUP BY t.Region
)

SELECT
    Region,
    ROUND(TotalTarget, 2) AS TotalTarget,
    ROUND(ActualSales, 2) AS ActualSales,
    ROUND(
        ActualSales / NULLIF(TotalTarget, 0) * 100, 2
    ) AS AchievementPercentage,
    RANK() OVER (
        ORDER BY ActualSales / NULLIF(TotalTarget, 0) DESC
    ) AS RegionRank
FROM RegionalPerformance
ORDER BY RegionRank;
