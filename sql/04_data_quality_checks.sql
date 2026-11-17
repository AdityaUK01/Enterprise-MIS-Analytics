USE enterprise_mis;

-- 1. Duplicate Order IDs
SELECT OrderID, COUNT(*) AS DuplicateCount
FROM Orders
GROUP BY OrderID
HAVING COUNT(*) > 1;

-- 2. Missing critical order fields
SELECT
    COUNT(*) AS TotalOrders,
    SUM(OrderID IS NULL) AS MissingOrderID,
    SUM(OrderDate IS NULL) AS MissingOrderDate,
    SUM(CustomerID IS NULL) AS MissingCustomerID,
    SUM(ProductID IS NULL) AS MissingProductID,
    SUM(EmployeeID IS NULL) AS MissingEmployeeID
FROM Orders;

-- 3. Invalid quantities and financial values
SELECT
    SUM(Quantity <= 0) AS InvalidQuantity,
    SUM(SalesAmount < 0) AS NegativeSales,
    SUM(CostAmount < 0) AS NegativeCost,
    SUM(SalesAmount IS NULL) AS MissingSales,
    SUM(CostAmount IS NULL) AS MissingCost
FROM Orders;

-- 4. Missing customer, product and employee references
SELECT
    (SELECT COUNT(*)
     FROM Orders o
     LEFT JOIN Customers c ON o.CustomerID = c.CustomerID
     WHERE c.CustomerID IS NULL) AS MissingCustomers,

    (SELECT COUNT(*)
     FROM Orders o
     LEFT JOIN Products p ON o.ProductID = p.ProductID
     WHERE p.ProductID IS NULL) AS MissingProducts,

    (SELECT COUNT(*)
     FROM Orders o
     LEFT JOIN Employees e ON o.EmployeeID = e.EmployeeID
     WHERE e.EmployeeID IS NULL) AS MissingEmployees;

-- 5. Order status distribution
SELECT
    OrderStatus,
    COUNT(*) AS TotalOrders,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM Orders), 2) AS Percentage
FROM Orders
GROUP BY OrderStatus;