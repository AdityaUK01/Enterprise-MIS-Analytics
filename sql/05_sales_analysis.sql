USE enterprise_mis;

-- 1. Overall Business Performance

SELECT
    COUNT(*) AS TotalOrders,
    SUM(Quantity) AS TotalQuantity,
    ROUND(SUM(SalesAmount), 2) AS TotalSales,
    ROUND(SUM(CostAmount), 2) AS TotalCost,
    ROUND(SUM(SalesAmount - CostAmount), 2) AS TotalProfit,
    ROUND(
        SUM(SalesAmount - CostAmount)
        / SUM(SalesAmount) * 100, 2
    ) AS ProfitMargin
FROM Orders;