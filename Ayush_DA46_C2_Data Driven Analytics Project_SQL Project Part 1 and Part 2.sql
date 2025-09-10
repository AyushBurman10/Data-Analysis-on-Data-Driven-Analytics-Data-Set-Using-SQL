-- Project Part 1


use modelcarsdb;
show tables;
select * from customers;
-- Task 1.1
select customernumber, customername, creditlimit
from customers
order by creditlimit desc
limit 10;

-- Task 1.2
select country, avg(creditlimit) as average_credit_limit
from customers
group by country
order by average_credit_limit desc;

-- Task 1.3
SELECT c.state, COUNT(c.customerNumber) AS customer_count
FROM customers c
LEFT JOIN offices o ON c.state = o.state
WHERE c.state IS NOT NULL
GROUP BY c.state
ORDER BY customer_count DESC;


-- Task 1.4
SELECT c.customerNumber, c.customerName
FROM customers c
LEFT JOIN orders o ON c.customerNumber = o.customerNumber
WHERE o.orderNumber IS NULL;

-- Task 1.5
SELECT c.customerNumber, c.customerName, SUM(p.amount) AS total_sales
FROM customers c
JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerNumber, c.customerName
ORDER BY total_sales DESC;

-- Task 1.6
SELECT c.customerNumber, c.customerName, 
       e.employeeNumber, CONCAT(e.firstName, ' ', e.lastName) AS sales_rep_name, 
       e.jobTitle
FROM customers c
JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
ORDER BY c.customerNumber;

-- Task 1.7
SELECT c.customerNumber, c.customerName, 
       p.checkNumber, p.paymentDate, p.amount
FROM customers c
LEFT JOIN payments p 
    ON c.customerNumber = p.customerNumber
    AND p.paymentDate = (
        SELECT MAX(p2.paymentDate)
        FROM payments p2
        WHERE p2.customerNumber = c.customerNumber
    )
ORDER BY c.customerNumber;

-- Task 1.8
SELECT c.customerNumber, c.customerName, 
       c.creditLimit, 
       SUM(od.quantityOrdered * od.priceEach) AS total_order_value
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerNumber, c.customerName, c.creditLimit
HAVING total_order_value > c.creditLimit
ORDER BY total_order_value DESC;

-- Task 1.9
SELECT DISTINCT c.customerNumber, c.customerName
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
JOIN productlines pl ON p.productLine = pl.productLine
WHERE pl.productLine = 'Electronics'
ORDER BY c.customerName;

-- Task 1.10
SELECT DISTINCT c.customerNumber, c.customerName
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
WHERE p.buyPrice = (SELECT MAX(buyPrice) FROM products)
ORDER BY c.customerName;

-- Task 2.1
SELECT o.city AS officeLocation, COUNT(e.employeeNumber) AS employee_count
FROM offices o
JOIN employees e ON o.officeCode = e.officeCode
GROUP BY o.city
ORDER BY employee_count DESC;


-- Task 2.2
SELECT o.officeCode, COUNT(e.employeeNumber) AS employeeCount
FROM offices o
LEFT JOIN employees e ON o.officeCode = e.officeCode
GROUP BY o.officeCode
HAVING employeeCount < (SELECT AVG(empCount) FROM 
                        (SELECT COUNT(employeeNumber) AS empCount 
                         FROM employees 
                         GROUP BY officeCode) AS avgEmployees);
                         
-- Task 2.3
SELECT officeCode, city AS officeLocation, territory
FROM offices
ORDER BY territory IS NULL DESC, city;

-- Task 2.4
SELECT o.officeCode, o.city AS officeLocation, 
       COUNT(e.employeeNumber) AS totalEmployees, 
       COALESCE(SUM(p.amount), 0) AS totalSales
FROM offices o
LEFT JOIN employees e ON o.officeCode = e.officeCode
LEFT JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY o.officeCode, o.city
HAVING totalEmployees = 0
ORDER BY totalSales DESC;

-- Task 2.5
SELECT o.officeCode, o.city AS officeLocation, 
       SUM(p.amount) AS totalSales
FROM offices o
JOIN employees e ON o.officeCode = e.officeCode
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY o.officeCode, o.city
ORDER BY totalSales DESC
LIMIT 1;

-- Task 2.6
SELECT o.officeCode, o.city AS officeLocation, 
       COUNT(e.employeeNumber) AS totalEmployees
FROM offices o
JOIN employees e ON o.officeCode = e.officeCode
GROUP BY o.officeCode, o.city
ORDER BY totalEmployees DESC
LIMIT 1;

-- Task 2.7
SELECT o.officeCode, o.city AS officeLocation, 
       AVG(c.creditLimit) AS avgCreditLimit
FROM offices o
JOIN employees e ON o.officeCode = e.officeCode
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
GROUP BY o.officeCode, o.city;

-- Task 2.8
SELECT country, COUNT(officeCode) AS numberOfOffices
FROM offices
GROUP BY country;

-- Task 3.1
SELECT p.productLine, 
       COUNT(p.productCode) AS numberOfProducts, 
       AVG(p.buyPrice) AS avgPrice
FROM products p
GROUP BY p.productLine
ORDER BY avgPrice DESC;

-- Task 3.2
SELECT productLine, 
       AVG(buyPrice) AS avgPrice
FROM products
GROUP BY productLine
ORDER BY avgPrice DESC
LIMIT 1;

-- Task 3.3
SELECT p.productCode, 
       p.productName, 
       p.productLine, 
       p.MSRP, 
       SUM(od.quantityOrdered * od.priceEach) AS totalSalesAmount
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
WHERE p.MSRP BETWEEN 50 AND 100
GROUP BY p.productCode, p.productName, p.productLine, p.MSRP
ORDER BY totalSalesAmount DESC;

-- Task 3.4
SELECT p.productLine, 
       SUM(od.quantityOrdered * od.priceEach) AS totalSalesAmount
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productLine
ORDER BY totalSalesAmount DESC;

-- Task 3.5
SELECT productCode, 
       productName, 
       productLine, 
       quantityInStock
FROM products
WHERE quantityInStock < 10
ORDER BY quantityInStock asc
LIMIT 10;

-- Task 3.6
SELECT p.productCode, 
       p.productName, 
       p.productLine, 
       p.MSRP, 
       (SELECT AVG(MSRP) 
        FROM products 
        WHERE productLine = p.productLine) AS avgMSRP
FROM products p
WHERE p.MSRP = (SELECT MAX(MSRP) FROM products);

-- Task 3.7
SELECT p.productCode, 
       p.productName, 
       SUM(od.quantityOrdered * od.priceEach) AS totalSales
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName
ORDER BY totalSales DESC;

-- Task 3.8
DELIMITER //

CREATE PROCEDURE GetTopSellingProducts(IN topN INT)
BEGIN
    SELECT p.productCode, 
           p.productName, 
           SUM(od.quantityOrdered) AS totalQuantityOrdered
    FROM products p
    JOIN orderdetails od ON p.productCode = od.productCode
    GROUP BY p.productCode, p.productName
    ORDER BY totalQuantityOrdered DESC
    LIMIT topN;
END //

DELIMITER ;

CALL GetTopSellingProducts(5);

-- Task 3.9
SELECT p.productCode, 
       p.productName, 
       p.quantityInStock, 
       pl.productLine
FROM products p
JOIN productlines pl ON p.productLine = pl.productLine
WHERE p.quantityInStock < 10
AND pl.productLine IN ('Classic Cars', 'Motorcycles')
ORDER BY p.quantityInStock ASC;


-- Task 3.10
SELECT p.productName, 
       COUNT(DISTINCT c.customerNumber) AS totalCustomers
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON od.orderNumber = o.orderNumber
JOIN customers c ON o.customerNumber = c.customerNumber
GROUP BY p.productCode, p.productName
HAVING COUNT(DISTINCT c.customerNumber) > 10
ORDER BY totalCustomers DESC;

-- Task 3.11
SELECT p.productName, 
       pl.productLine, 
       COUNT(od.orderNumber) AS totalOrders
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
JOIN productlines pl ON p.productLine = pl.productLine
GROUP BY p.productCode, p.productName, pl.productLine
HAVING totalOrders > (
    SELECT AVG(order_count)
    FROM (
        SELECT p2.productLine, 
               COUNT(od2.orderNumber) AS order_count
        FROM products p2
        JOIN orderdetails od2 ON p2.productCode = od2.productCode
        GROUP BY p2.productCode, p2.productLine
    ) AS avg_orders_per_line
    WHERE avg_orders_per_line.productLine = pl.productLine
)
ORDER BY pl.productLine, totalOrders DESC;


-- -- -- -- -- -- -- -- -- --

-- SQL Project Part 2
use modelcarsdb;
show tables;

-- Task 1.1
SELECT COUNT(*) AS totalEmployees
FROM employees;

-- Task 1.2
SELECT employeeNumber, 
       lastName, 
       firstName, 
       email, 
       jobTitle, 
       officeCode 
FROM employees;

-- Task 1.3
SELECT jobTitle, COUNT(*) AS employeeCount
FROM employees
GROUP BY jobTitle
ORDER BY employeeCount DESC;

-- Task 1.4
SELECT employeeNumber, lastName, firstName, email, jobTitle 
FROM employees
WHERE reportsTo IS NULL;

-- Task 1.5
SELECT e.employeeNumber, 
       e.lastName, 
       e.firstName, 
       e.jobTitle, 
       SUM(p.amount) AS totalSales
FROM employees e
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY e.employeeNumber, e.lastName, e.firstName, e.jobTitle
ORDER BY totalSales DESC;

-- Task 1.6
WITH SalesRepTotal AS (
    SELECT e.employeeNumber, 
           e.lastName, 
           e.firstName, 
           e.jobTitle, 
           SUM(p.amount) AS totalSales
    FROM employees e
    JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
    JOIN payments p ON c.customerNumber = p.customerNumber
    GROUP BY e.employeeNumber, e.lastName, e.firstName, e.jobTitle
)
SELECT employeeNumber, lastName, firstName, jobTitle, totalSales
FROM SalesRepTotal
WHERE totalSales = (SELECT MAX(totalSales) FROM SalesRepTotal);


-- Task 1.7
CREATE VIEW EmployeeSales AS
SELECT e.employeeNumber, 
       e.lastName, 
       e.firstName, 
       e.jobTitle, 
       o.officeCode, 
       o.city AS officeCity, 
       SUM(p.amount) AS totalSales
FROM employees e
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN payments p ON c.customerNumber = p.customerNumber
JOIN offices o ON e.officeCode = o.officeCode
GROUP BY e.employeeNumber, e.lastName, e.firstName, e.jobTitle, o.officeCode, o.city;

SELECT es.employeeNumber, 
       es.lastName, 
       es.firstName, 
       es.jobTitle, 
       es.officeCity, 
       es.totalSales
FROM EmployeeSales es
JOIN (
    SELECT officeCode, AVG(totalSales) AS avgOfficeSales
    FROM EmployeeSales
    GROUP BY officeCode
) AS OfficeAvgSales
ON es.officeCode = OfficeAvgSales.officeCode
WHERE es.totalSales > OfficeAvgSales.avgOfficeSales;

-- Task 2.1
SELECT c.customerNumber, 
       c.customerName, 
       AVG(p.amount) AS averageOrderAmount
FROM customers c
JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerNumber, c.customerName
ORDER BY averageOrderAmount DESC;

-- Task 2.2
SELECT 
    YEAR(orderDate) AS orderYear,
    MONTH(orderDate) AS orderMonth,
    COUNT(orderNumber) AS totalOrders
FROM orders
GROUP BY orderYear, orderMonth
ORDER BY orderYear DESC, orderMonth DESC;

-- Task 2.3
SELECT orderNumber, orderDate, requiredDate, shippedDate, status, customerNumber
FROM orders
WHERE status = 'Pending'
ORDER BY orderDate DESC;

-- Task 2.4
SELECT 
    o.orderNumber,
    o.orderDate,
    o.status,
    c.customerNumber,
    c.customerName,
    c.contactLastName,
    c.contactFirstName,
    c.phone,
    c.city,
    c.country
FROM orders o
JOIN customers c ON o.customerNumber = c.customerNumber
ORDER BY o.orderDate DESC;

-- Task 2.5
SELECT 
    orderNumber,
    orderDate,
    status,
    customerNumber
FROM orders
ORDER BY orderDate DESC
LIMIT 1;

-- Task 2.6
SELECT 
    od.orderNumber,
    SUM(od.quantityOrdered * od.priceEach) AS totalSales
FROM orderdetails od
JOIN orders o ON od.orderNumber = o.orderNumber
GROUP BY od.orderNumber
ORDER BY totalSales DESC;

-- Task 2.7
SELECT 
    od.orderNumber,
    SUM(od.quantityOrdered * od.priceEach) AS totalSales
FROM orderdetails od
JOIN orders o ON od.orderNumber = o.orderNumber
GROUP BY od.orderNumber
ORDER BY totalSales DESC
LIMIT 1;

-- Task 2.8
SELECT 
    o.orderNumber,
    o.orderDate,
    o.status,
    o.customerNumber,
    od.productCode,
    od.quantityOrdered,
    od.priceEach,
    (od.quantityOrdered * od.priceEach) AS totalOrderAmount
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
ORDER BY o.orderDate DESC, o.orderNumber;

-- Task 2.9
SELECT 
    p.productCode,
    p.productName,
    COUNT(od.orderNumber) AS orderCount
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
GROUP BY p.productCode, p.productName
ORDER BY orderCount DESC;

-- Task 2.10
SELECT 
    od.orderNumber,
    SUM(od.quantityOrdered * od.priceEach) AS totalRevenue
FROM orderdetails od
GROUP BY od.orderNumber
ORDER BY totalRevenue DESC;

-- Task 2.11
SELECT 
    od.orderNumber,
    COUNT(od.orderNumber) AS orderCount,
    SUM(od.quantityOrdered * od.priceEach) AS totalRevenue
FROM orderdetails od
GROUP BY od.orderNumber
ORDER BY totalRevenue DESC
LIMIT 10;

-- Task 2.12
SELECT 
    o.orderNumber,
    o.orderDate,
    o.status,
    c.customerName,
    p.productCode,
    p.productName,
    p.productLine,
    od.quantityOrdered,
    od.priceEach,
    (od.quantityOrdered * od.priceEach) AS totalPrice
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
JOIN customers c ON o.customerNumber = c.customerNumber
ORDER BY o.orderDate DESC;

-- Task 2.13
SELECT 
    orderNumber,
    orderDate,
    requiredDate,
    shippedDate,
    status,
    customerNumber
FROM orders
WHERE shippedDate > requiredDate
ORDER BY shippedDate DESC;

-- Task 2.14
SELECT 
    productCode, 
    COUNT(orderNumber) AS orderCount
FROM orderdetails
GROUP BY productCode
ORDER BY orderCount DESC
LIMIT 10;  -- Top 10 most ordered products

SELECT 
    od1.productCode AS product_A, 
    od2.productCode AS product_B, 
    COUNT(*) AS combinationCount
FROM orderdetails od1
JOIN orderdetails od2 
    ON od1.orderNumber = od2.orderNumber  -- Same order
    AND od1.productCode < od2.productCode  -- Avoid duplicate pairs (A-B and B-A)
GROUP BY product_A, product_B
ORDER BY combinationCount DESC
LIMIT 10;  -- Top 10 most popular product combinations

-- 2.15
SELECT 
    od.orderNumber, 
    SUM(od.quantityOrdered * od.priceEach) AS totalRevenue
FROM orderdetails od
GROUP BY od.orderNumber
ORDER BY totalRevenue DESC
LIMIT 10;

-- Task 2.16
DELIMITER //

CREATE TRIGGER update_credit_limit_after_order
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE order_total DECIMAL(10,2);
    
    -- Calculate total order amount
    SELECT SUM(od.quantityOrdered * od.priceEach)
    INTO order_total
    FROM orderdetails od
    WHERE od.orderNumber = NEW.orderNumber;

    -- Update customer credit limit
    UPDATE customers 
    SET creditLimit = creditLimit - IFNULL(order_total, 0)
    WHERE customerNumber = NEW.customerNumber;
END //

DELIMITER ;

SELECT customerNumber, creditLimit FROM customers WHERE customerNumber = 103;

-- Task 2.17
CREATE TABLE product_inventory_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    productCode VARCHAR(15),
    old_quantity INT DEFAULT NULL,
    new_quantity INT NOT NULL,
    change_type ENUM('INSERT', 'UPDATE'),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE TRIGGER log_product_quantity_insert
BEFORE INSERT ON orderdetails
FOR EACH ROW
BEGIN
    -- Insert a new log entry when a new order is placed
    INSERT INTO product_inventory_log (productCode, new_quantity, change_type)
    VALUES (NEW.productCode, NEW.quantityOrdered, 'INSERT');
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER log_product_quantity_update
BEFORE UPDATE ON orderdetails
FOR EACH ROW
BEGIN
    -- Insert a log entry before an update, tracking old and new quantities
    INSERT INTO product_inventory_log (productCode, old_quantity, new_quantity, change_type)
    VALUES (NEW.productCode, OLD.quantityOrdered, NEW.quantityOrdered, 'UPDATE');
END //

DELIMITER ;

SELECT * FROM product_inventory_log ORDER BY change_date DESC;

-- -- -- -- -- -- -- -- -- --












