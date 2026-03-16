-- E-COMMERCE CUSTOMER BEHAVIOR ANALYSIS

-- 1. Database setup
CREATE DATABASE ecommerce_sales;
USE ecommerce_sales;

-- 2. Table Structure
CREATE TABLE ecommerce_customer_behavior (
    Order_ID VARCHAR(50),
    Customer_ID VARCHAR(50),
    Date DATE,
    Age INT,
    Gender VARCHAR(10),
    City VARCHAR(50),
    Product_Category VARCHAR(50),
    Unit_Price DECIMAL(10,2),
    Quantity INT,
    Discount_Amount DECIMAL(10,2),
    Total_Amount DECIMAL(10,2),
    Payment_Method VARCHAR(50),
    Device_Type VARCHAR(50),
    Session_Duration_Minutes INT,
    Pages_Viewed INT,
    Is_Returning_Customer VARCHAR(10),
    Delivery_Time_Days INT,
    Customer_Rating INT
);

-- 3. Data Import Note
-- Data is imported using MySQL Data Import Wizard

-- 4.  Analysis Queries
-- SALES PERFORMANCE ANALYSIS

-- Find the total revenue generated.
SELECT 
    ROUND(SUM(Total_Amount), 2) AS Total_Revenue
FROM
    ecommerce_customer_behavior;

-- Find the average order value.
SELECT 
    ROUND(AVG(Total_Amount), 2) AS Average_order_value
FROM
    ecommerce_customer_behavior;

-- Show total quantity of products sold.
SELECT 
    SUM(Quantity) AS Total_Quantity
FROM
    ecommerce_customer_behavior;

-- Find total sales per day.
SELECT 
    Date, ROUND(SUM(Total_Amount), 2) AS Total_Daily_Sales
FROM
    ecommerce_customer_behavior
GROUP BY Date
ORDER BY Date;

-- Find the top 5 cities with highest sales.
SELECT 
    City, ROUND(SUM(Total_Amount), 2) AS Total_Sales
FROM
    ecommerce_customer_behavior
GROUP BY City
ORDER BY Total_Sales DESC
LIMIT 5;

-- Count orders per month.
SELECT 
    COUNT(Order_ID) AS Total_Orders,
    DATE_FORMAT(STR_TO_DATE(date, '%Y-%m-%d'), '%Y-%m') AS Month
FROM
    ecommerce_customer_behavior
GROUP BY Month
ORDER BY Month;

-- Find monthly revenue trend.
SELECT 
    ROUND(SUM(Total_Amount), 2) AS Total_Revenue,
    DATE_FORMAT(STR_TO_DATE(date, '%Y-%m-%d'), '%Y-%m') AS Month
FROM
    ecommerce_customer_behavior
GROUP BY Month
ORDER BY Month;

-- CUSTOMER BEHAVIOR ANALYSIS

-- Count the total number of unique customers.
SELECT 
    COUNT(DISTINCT Customer_ID) AS Unique_customers
FROM
    ecommerce_customer_behavior;

--  Do returning customers spend more than new customers?
SELECT 
    ROUND(AVG(Total_Amount), 2) AS Avg_Spending,
    Is_Returning_Customer
FROM
    ecommerce_customer_behavior
GROUP BY Is_Returning_Customer;

-- Find the top 10 customers by total spending.
SELECT 
    Customer_ID, ROUND(SUM(Total_Amount), 2) AS Total_Spending
FROM
    ecommerce_customer_behavior
GROUP BY Customer_ID
ORDER BY Total_Spending DESC
LIMIT 10;

-- Rank customers by total spending.
SELECT Customer_ID,
	ROUND(SUM(Total_Amount),2) AS Total_Spent,
	RANK() OVER(ORDER BY SUM(Total_Amount) DESC) AS Ranking
FROM
	ecommerce_customer_behavior
GROUP BY Customer_ID;

-- Identify repeat customers (customers with more than 1 order).
SELECT 
    Customer_ID, COUNT(Order_ID) AS order_count
FROM
    ecommerce_customer_behavior
GROUP BY Customer_ID
HAVING COUNT(Order_ID) > 1;

-- PRODUCT PERFORMANCE ANALYSIS

-- Identify the rating group that contributes the highest revenue.
SELECT 
    ROUND(SUM(Total_Amount), 2) AS Highest_Revenue,
    Customer_Rating
FROM
    ecommerce_customer_behavior
GROUP BY Customer_Rating
ORDER BY Highest_Revenue DESC
LIMIT 1;

-- Calculate average customer age by product category.
SELECT 
    ROUND(AVG(Age), 2) AS Avg_Age, Product_Category
FROM
    ecommerce_customer_behavior
GROUP BY Product_Category
ORDER BY Avg_Age ASC;

-- What is the average rating by product category?
SELECT 
    Product_Category,
    ROUND(AVG(Customer_Rating), 2) AS Avg_Rating
FROM
    ecommerce_customer_behavior
GROUP BY Product_Category;

-- CUSTOMER EXPERIENCE & DELIVERY ANALYSIS

-- Calculate average delivery time by city.
SELECT 
    City, AVG(Delivery_Time_Days) AS Avg_Delivery
FROM
    ecommerce_customer_behavior
GROUP BY City
ORDER BY Avg_Delivery DESC;

-- Does long delivery time reduce customer ratings?
SELECT 
    Delivery_Time_Days, AVG(Customer_Rating) AS Avg_Rating
FROM
    ecommerce_customer_behavior
GROUP BY Delivery_Time_Days
ORDER BY Delivery_Time_Days;

-- Average customer rating for each city and rank cities by it.
SELECT City, 
	ROUND(AVG(Customer_Rating),2) AS Avg_Rating,
	RANK() OVER (ORDER BY ROUND(AVG(Customer_Rating),2) DESC) AS City_Rank
FROM
	ecommerce_customer_behavior
GROUP BY City
ORDER BY City_Rank;

-- DEVICE & PLATFORM USAGE ANALYSIS

-- Count orders by device type.
SELECT 
    COUNT(Order_ID) AS Total_Orders, Device_Type
FROM
    ecommerce_customer_behavior
GROUP BY Device_Type
ORDER BY Total_Orders DESC;

-- What is the average number of pages viewed per session?
SELECT 
    ROUND(AVG(Pages_Viewed), 2) AS Avg_pages_viewed,
    Session_Duration_Minutes
FROM
    ecommerce_customer_behavior
GROUP BY Session_Duration_Minutes
ORDER BY Session_Duration_Minutes;

-- Calculate Revenue by Device Type and Average Session.
SELECT 
    Device_Type,
    ROUND(SUM(Total_Amount), 2) AS Total_Revenue,
    ROUND(AVG(Session_Duration_Minutes), 2) AS Avg_Session
FROM
    ecommerce_customer_behavior
GROUP BY Device_Type
ORDER BY Total_Revenue DESC;

-- PAYMENT & DISCOUNT ANALYSIS

-- Count orders by payment method.
SELECT 
    COUNT(Order_ID) AS Total_Orders, Payment_Method
FROM
    ecommerce_customer_behavior
GROUP BY Payment_Method
ORDER BY Total_Orders DESC;

-- Calculate total discount amount given.
SELECT 
    ROUND(SUM(Discount_Amount), 2) AS Total_Discount
FROM
    ecommerce_customer_behavior;

-- ADVANCE ANALYTICS & REVENUE SEGMENTATION ANALYSIS

-- Year-wise revenue split between new and returning customers.
SELECT 
    YEAR(STR_TO_DATE(Date, '%Y-%m-%d')) AS Year,
    Is_Returning_Customer,
    ROUND(SUM(Total_Amount), 2) AS Total_Revenue
FROM
    ecommerce_customer_behavior
GROUP BY Year , Is_Returning_Customer
ORDER BY Year , Is_Returning_Customer;

-- Segment customers into high, medium, and low spenders. 
SELECT 
    Customer_ID,
    ROUND(SUM(Total_Amount), 2) AS Total_Spent,
    CASE
        WHEN ROUND(SUM(Total_Amount), 2) > 1000 THEN 'High Value'
        WHEN ROUND(SUM(Total_Amount), 2) BETWEEN 500 AND 1000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Customer_Segment
FROM
    ecommerce_customer_behavior
GROUP BY Customer_ID;

-- Show cumulative revenue growth over time.
SELECT Date,
       ROUND(SUM(Total_Amount),2) AS Daily_Sales,
       SUM(SUM(Total_Amount)) OVER(ORDER BY Date) AS Cumulative_Revenue
FROM ecommerce_customer_behavior
GROUP BY Date
ORDER BY Date;

-- Rank cities by total sales
SELECT City,
       round(SUM(Total_Amount),2) AS Total_Sales,
       RANK() OVER(ORDER BY SUM(Total_Amount) DESC) AS City_Rank
FROM ecommerce_customer_behavior
GROUP BY City;