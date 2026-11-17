USE enterprise_mis;

-- Customers
LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Customers.csv'
INTO TABLE Customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(CustomerID, CustomerName, City, Region, @SignupDate)
SET SignupDate = STR_TO_DATE(@SignupDate, '%Y-%m-%d');

-- Employees
LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Employees.csv'
INTO TABLE Employees
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(EmployeeID, EmployeeName, Region, Department);

-- Products
LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Products.csv'
INTO TABLE Products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ProductID, ProductName, Category, UnitCost, UnitPrice, StockQty, ReorderLevel);

-- Targets: YYYY-MM converted to first day of month
LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Targets.csv'
INTO TABLE Targets
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@TargetMonth, Region, SalesTarget)
SET Month = STR_TO_DATE(CONCAT(@TargetMonth, '-01'), '%Y-%m-%d');

-- Orders: Excel serial date converted to MySQL DATE
LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Orders.csv'
INTO TABLE Orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(OrderID, @OrderDate, CustomerID, ProductID, EmployeeID,
 Quantity, DiscountRate, SalesAmount, CostAmount, OrderStatus)
SET OrderDate = DATE_ADD('1899-12-30', INTERVAL CAST(@OrderDate AS UNSIGNED) DAY);

-- Final row count verification
SELECT 'Customers' AS TableName, COUNT(*) AS TotalRows FROM Customers
UNION ALL
SELECT 'Employees', COUNT(*) FROM Employees
UNION ALL
SELECT 'Products', COUNT(*) FROM Products
UNION ALL
SELECT 'Targets', COUNT(*) FROM Targets
UNION ALL
SELECT 'Orders', COUNT(*) FROM Orders;


