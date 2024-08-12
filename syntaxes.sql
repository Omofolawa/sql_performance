-- Project Execution: SQL Performance Optimization and Key Terminologies

-- Step 1: Set Up the Sample Database
-- Create the Customers table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY,
    CustomerName NVARCHAR(100),
    ContactName NVARCHAR(100),
    Country NVARCHAR(50)
);

-- Create the Products table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY,
    ProductName NVARCHAR(100),
    SupplierID INT,
    CategoryID INT,
    Unit NVARCHAR(20),
    Price DECIMAL(10, 2)
);

-- Create the Orders table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    OrderDate DATE,
    ShipperID INT
);

-- Create the OrderDetails table
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY IDENTITY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT,
    UnitPrice DECIMAL(10, 2)
);

-- Insert sample data (example with random data generation)
DECLARE @i INT = 1;
WHILE @i <= 10000
BEGIN
    INSERT INTO Customers (CustomerName, ContactName, Country)
    VALUES ('Customer ' + CAST(@i AS NVARCHAR(10)), 'Contact ' + CAST(@i AS NVARCHAR(10)), 'Country ' + CAST((@i % 10) + 1 AS NVARCHAR(10)));

    SET @i = @i + 1;
END;

-- DECLARE @i INT = 1;

-- This statement declares a variable @i of type INT (integer) and initializes it with the value 1. This variable will be used as a counter in the loop.
WHILE @i <= 10000

-- This starts a loop that will continue to run as long as the value of @i is less than or equal to 10,000. This means the loop will run 10,000 times.
BEGIN...END

-- These keywords define the block of code that will be executed repeatedly during each iteration of the loop.
-- INSERT INTO Customers (CustomerName, ContactName, Country)

-- This SQL statement inserts a new row into the Customers table.
-- VALUES ('Customer ' + CAST(@i AS NVARCHAR(10)), 'Contact ' + CAST(@i AS NVARCHAR(10)), 'Country ' + CAST((@i % 10) + 1 AS NVARCHAR(10)));

-- This inserts values into the CustomerName, ContactName, and Country columns.
-- 'Customer ' + CAST(@i AS NVARCHAR(10)): Creates a customer name by concatenating the string 'Customer ' with the value of @i, converted to a string.
---'Contact ' + CAST(@i AS NVARCHAR(10)): Creates a contact name in the same way.
-- 'Country ' + CAST((@i % 10) + 1 AS NVARCHAR(10)): Generates a country name by taking the modulo of @i with 10, adding 1, and converting it to a string. This results in values from 'Country 1' to 'Country 10'.
-- SET @i = @i + 1;

-- This increments the counter @i by 1 after each iteration, ensuring the loop progresses toward completion.


DECLARE @j INT = 1;
WHILE @j <= 50000
BEGIN
    INSERT INTO Products (ProductName, SupplierID, CategoryID, Unit, Price)
    VALUES ('Product ' + CAST(@j AS NVARCHAR(10)), @j % 50 + 1, @j % 10 + 1, 'Unit ' + CAST(@j AS NVARCHAR(10)), RAND() * 100);

    SET @j = @j + 1;
END;

--(Similar structure to the customer data insertion loop, but this loop runs 50,000 times to insert data into the Products table.

RAND() * 100

This generates a random price between 0 and 100 for each product. RAND() returns a random float between 0 and 1, which is then multiplied by 100.)


-- Insert sample data for Orders and OrderDetails with nested loops
DECLARE @k INT = 1;
WHILE @k <= 10000
BEGIN
    INSERT INTO Orders (CustomerID, OrderDate, ShipperID)
    VALUES (@k % 10000 + 1, DATEADD(DAY, -@k, GETDATE()), @k % 5 + 1);

    SET @k = @k + 1;
END;

--(his loop inserts 10,000 rows into the Orders table.

@k % 10000 + 1

This assigns each order to a customer ID, cycling through IDs from 1 to 10,000.
DATEADD(DAY, -@k, GETDATE())

This sets the OrderDate by subtracting @k days from the current date. This creates a range of order dates in the past.
@k % 5 + 1

This assigns each order a ShipperID in a cyclic manner from 1 to 5.)

DECLARE @l INT = 1;
WHILE @l <= 50000
BEGIN
    INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice)
    VALUES (@l % 10000 + 1, @l % 50000 + 1, @l % 10 + 1, RAND() * 100);

    SET @l = @l + 1;
END;

-- (his loop inserts 50,000 rows into the OrderDetails table.

@l % 10000 + 1 and @l % 50000 + 1

These statements assign OrderID and ProductID values in a cyclic manner, ensuring every OrderID and ProductID pair is used.
@l % 10 + 1

This sets the Quantity column to a value between 1 and 10.
RAND() * 100

This generates a random unit price between 0 and 100.)



Step 2: Performance Testing and Optimization
-- A complex query with multiple JOINs and filtering conditions
SELECT 
    C.CustomerName,
    O.OrderID,
    OD.ProductID,
    P.ProductName,
    OD.Quantity,
    OD.UnitPrice,
    O.OrderDate
FROM 
    Customers C
    JOIN Orders O ON C.CustomerID = O.CustomerID
    JOIN OrderDetails OD ON O.OrderID = OD.OrderID
    JOIN Products P ON OD.ProductID = P.ProductID
WHERE 
    C.Country = 'Country 1'
    AND O.OrderDate BETWEEN '2022-01-01' AND '2023-01-01'
ORDER BY 
    O.OrderDate DESC;

Analyze Execution Plan:

Use SET STATISTICS TIME, IO ON; before running the query to get timing and I/O statistics.
Execute EXPLAIN or view the execution plan in SQL Server Management Studio (SSMS) to identify potential bottlenecks.
Optimization Techniques:

Indexing:
-- Create indexes on frequently used columns in WHERE and JOIN clauses
CREATE INDEX IDX_Customers_Country ON Customers(Country);
CREATE INDEX IDX_Orders_OrderDate ON Orders(OrderDate);
CREATE INDEX IDX_OrderDetails_ProductID ON OrderDetails(ProductID);

Query Refactoring:

Compare performance using a JOIN vs. a subquery:
-- Using a subquery
SELECT 
    C.CustomerName,
    O.OrderID,
    P.ProductName,
    OD.Quantity,
    OD.UnitPrice,
    O.OrderDate
FROM 
    Customers C
    JOIN Orders O ON C.CustomerID = O.CustomerID
    JOIN OrderDetails OD ON O.OrderID = OD.OrderID
    JOIN Products P ON OD.ProductID = P.ProductID
WHERE 
    O.CustomerID IN (SELECT CustomerID FROM Customers WHERE Country = 'Country 1')
    AND O.OrderDate BETWEEN '2022-01-01' AND '2023-01-01'
ORDER BY 
    O.OrderDate DESC;
