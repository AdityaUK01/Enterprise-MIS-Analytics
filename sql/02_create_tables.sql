USE enterprise_mis;

CREATE TABLE Customers (
    CustomerID VARCHAR(20) PRIMARY KEY,
    CustomerName VARCHAR(100),
    City VARCHAR(100),
    Region VARCHAR(50),
    SignupDate DATE
);

CREATE TABLE Employees (
    EmployeeID VARCHAR(20) PRIMARY KEY,
    EmployeeName VARCHAR(100),
    Region VARCHAR(50),
    Department VARCHAR(100)
);

CREATE TABLE Products (
    ProductID VARCHAR(20) PRIMARY KEY,
    ProductName VARCHAR(150),
    Category VARCHAR(100),
    UnitCost DECIMAL(12,2),
    UnitPrice DECIMAL(12,2),
    StockQty INT,
    ReorderLevel INT
);

CREATE TABLE Targets (
    Month DATE,
    Region VARCHAR(50),
    SalesTarget DECIMAL(14,2),
    PRIMARY KEY (Month, Region)
);

CREATE TABLE Orders (
    OrderID VARCHAR(30) PRIMARY KEY,
    OrderDate DATE,
    CustomerID VARCHAR(20),
    ProductID VARCHAR(20),
    EmployeeID VARCHAR(20),
    Quantity INT,
    DiscountRate DECIMAL(8,4),
    SalesAmount DECIMAL(14,2),
    CostAmount DECIMAL(14,2),
    OrderStatus VARCHAR(30),

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),

    CONSTRAINT fk_orders_product
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID),

    CONSTRAINT fk_orders_employee
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

SHOW TABLES;
