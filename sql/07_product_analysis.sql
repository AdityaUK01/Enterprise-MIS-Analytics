
USE enterprise_mis;

-- =====================================================
-- 1. OVERALL INVENTORY SUMMARY
-- =====================================================

SELECT
    COUNT(*) AS TotalProducts,
    SUM(StockQty) AS TotalStockUnits,
    SUM(CASE WHEN StockQty <= ReorderLevel THEN 1 ELSE 0 END)
        AS ProductsNeedingReorder,
    SUM(CASE WHEN StockQty = 0 THEN 1 ELSE 0 END)
        AS OutOfStockProducts,
    ROUND(SUM(StockQty * UnitCost), 2) AS TotalInventoryValue
FROM Products;


-- =====================================================
-- 2. PRODUCT STOCK STATUS
-- =====================================================

SELECT
    ProductID,
    ProductName,
    Category,
    StockQty,
    ReorderLevel,
    CASE
        WHEN StockQty = 0 THEN 'Out of Stock'
        WHEN StockQty <= ReorderLevel THEN 'Reorder Required'
        ELSE 'In Stock'
    END AS StockStatus
FROM Products
ORDER BY StockQty ASC;


-- =====================================================
-- 3. PRODUCTS REQUIRING REORDER
-- =====================================================

SELECT
    ProductID,
    ProductName,
    Category,
    StockQty,
    ReorderLevel,
    ReorderLevel - StockQty AS StockShortfall
FROM Products
WHERE StockQty <= ReorderLevel
ORDER BY StockShortfall DESC;


-- =====================================================
-- 4. CATEGORY-WISE INVENTORY SUMMARY
-- =====================================================

SELECT
    Category,
    COUNT(*) AS TotalProducts,
    SUM(StockQty) AS TotalStockUnits,
    ROUND(SUM(StockQty * UnitCost), 2) AS InventoryValue
FROM Products
GROUP BY Category
ORDER BY InventoryValue DESC;


-- =====================================================
-- 5. PRODUCT-WISE SALES AND QUANTITY
-- =====================================================

SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    p.StockQty,
    COALESCE(SUM(o.Quantity), 0) AS TotalUnitsOrdered,
    ROUND(COALESCE(SUM(o.SalesAmount), 0), 2) AS TotalSales,
    ROUND(
        COALESCE(SUM(o.SalesAmount - o.CostAmount), 0), 2
    ) AS TotalProfit
FROM Products p
LEFT JOIN Orders o
    ON p.ProductID = o.ProductID
GROUP BY
    p.ProductID,
    p.ProductName,
    p.Category,
    p.StockQty
ORDER BY TotalUnitsOrdered DESC;


-- =====================================================
-- 6. TOP 10 PRODUCTS BY SALES
-- =====================================================

SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    SUM(o.Quantity) AS UnitsOrdered,
    ROUND(SUM(o.SalesAmount), 2) AS TotalSales
FROM Products p
JOIN Orders o
    ON p.ProductID = o.ProductID
GROUP BY
    p.ProductID,
    p.ProductName,
    p.Category
ORDER BY TotalSales DESC
LIMIT 10;


-- =====================================================
-- 7. LOW STOCK PRODUCTS WITH SALES PERFORMANCE
-- =====================================================

SELECT
    p.ProductName,
    p.Category,
    p.StockQty,
    p.ReorderLevel,
    COALESCE(SUM(o.Quantity), 0) AS UnitsOrdered,
    ROUND(COALESCE(SUM(o.SalesAmount), 0), 2) AS TotalSales
FROM Products p
LEFT JOIN Orders o
    ON p.ProductID = o.ProductID
WHERE p.StockQty <= p.ReorderLevel
GROUP BY
    p.ProductID,
    p.ProductName,
    p.Category,
    p.StockQty,
    p.ReorderLevel
ORDER BY UnitsOrdered DESC;


-- =====================================================
-- 8. INVENTORY VALUE BY PRODUCT
-- =====================================================

SELECT
    ProductID,
    ProductName,
    Category,
    StockQty,
    UnitCost,
    ROUND(StockQty * UnitCost, 2) AS InventoryValue
FROM Products
ORDER BY InventoryValue DESC;


-- =====================================================
-- 9. PRODUCT SALES CONTRIBUTION
-- =====================================================

SELECT
    p.ProductName,
    p.Category,
    ROUND(SUM(o.SalesAmount), 2) AS ProductSales,
    ROUND(
        SUM(o.SalesAmount) * 100.0 /
        NULLIF((SELECT SUM(SalesAmount) FROM Orders), 0),
        2
    ) AS SalesContributionPercentage
FROM Products p
JOIN Orders o
    ON p.ProductID = o.ProductID
GROUP BY
    p.ProductID,
    p.ProductName,
    p.Category
ORDER BY ProductSales DESC;


-- =====================================================
-- 10. CATEGORY-WISE PROFITABILITY
-- =====================================================

SELECT
    p.Category,
    ROUND(SUM(o.SalesAmount), 2) AS TotalSales,
    ROUND(SUM(o.CostAmount), 2) AS TotalCost,
    ROUND(SUM(o.SalesAmount - o.CostAmount), 2) AS TotalProfit,
    ROUND(
        SUM(o.SalesAmount - o.CostAmount) /
        NULLIF(SUM(o.SalesAmount), 0) * 100,
        2
    ) AS ProfitMargin
FROM Products p
JOIN Orders o
    ON p.ProductID = o.ProductID
GROUP BY p.Category
ORDER BY TotalProfit DESC;
