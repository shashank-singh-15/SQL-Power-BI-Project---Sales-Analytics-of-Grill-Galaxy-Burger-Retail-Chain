-- First we will create a database for our Analysis
create database burger_store_sales;


/* After importing the table successfully
We will have a look at our table */
select * from grill_galaxy_sales;

-- Checking the schema for data type and column name
describe grill_galaxy_sales;


-- changing the data type for order_date column
update grill_galaxy_sales
set order_date2 = str_to_date(order_date2, '%d-%m-%Y');

alter table grill_galaxy_sales
modify column order_date2 date;


-- changing the data type for order_time column
update grill_galaxy_sales
set order_time = str_to_date(order_time, '%H:%i:%s');

alter table grill_galaxy_sales
modify column order_time time;


-- correcting the name of transaction_id column
alter table grill_galaxy_sales
change column ï»¿transaction_id transaction_id int;


-- checking for all the corrections we have made
describe grill_galaxy_sales;


-- Finding total sales for any specific month
select round(sum(order_quantity * unit_price),0) as sales_amount
from grill_galaxy_sales
where
month(order_date) = 4; -- sales_amount for April


-- Finding Month on Month increase or decrease in sales_amount
SELECT 
    MONTH(order_date) AS month,
    ROUND(SUM(unit_price * order_quantity),0) AS sales_amount, -- Total Sales in that particular month
    round((SUM(unit_price * order_quantity) - LAG(SUM(unit_price * order_quantity), 1)
    OVER (ORDER BY MONTH(order_date))) / LAG(SUM(unit_price * order_quantity), 1) 
    OVER (ORDER BY MONTH(order_date)) * 100) AS mom_increase_percentage -- MOM Increase or Decrease value in %
FROM 
    grill_galaxy_sales
WHERE 
    MONTH(order_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(order_date)
ORDER BY 
    MONTH(order_date);
    
    
   -- Finding total no of orders for any month
   select count(transaction_id) as total_orders
   from grill_galaxy_sales
   where
   month(order_date) = 2; -- February Month


-- Finding month on month increase or decrease in the no of orders placed
SELECT 
    MONTH(order_date) AS month,
    ROUND(COUNT(transaction_id)) AS total_orders,
    round((COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(order_date))) / LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(order_date)) * 100) AS mom_increase_percentage
FROM 
    grill_galaxy_sales
WHERE 
    MONTH(order_date) IN (2, 3) -- for February and March
GROUP BY 
    MONTH(order_date)
ORDER BY 
    MONTH(order_date);


-- Find total quantity of food items sold for a particular month
select monthname(order_date) as month,
sum(order_quantity) as quantity_ordered
   from grill_galaxy_sales
   where
   month(order_date) = 2 -- February Month
   group by monthname(order_date);
   
   
   -- Find month on month difference in quantity of food items sold
   SELECT 
    monthname(order_date) AS month,
    ROUND(SUM(order_quantity)) AS total_quantity_sold,
    round((SUM(order_quantity) - LAG(SUM(order_quantity), 1) 
    OVER (ORDER BY MONTHNAME(order_date))) / LAG(SUM(order_quantity), 1) 
    OVER (ORDER BY MONTHNAME(order_date)) * 100) AS mom_increase_percentage
FROM 
    grill_galaxy_sales
WHERE 
    MONTH(order_date) IN (4, 5)   -- for April and May
GROUP BY 
    monthname(order_date)
ORDER BY 
    MONTHNAME(order_date);
    
    
    /* Create a calendar based query which shows sales, orders & quantity 
    based on month and day selected */
    select
    order_date,
    concat(round(sum(unit_price * order_quantity)/1000,1),'K') as sales_amount,
    concat(round(sum(order_quantity)/1000,1), 'K') as quantity_ordered,
    concat(round(count(transaction_id)/1000,1),'K') as no_of_orders
    from grill_galaxy_sales
    where
    order_date = '2024-05-18'
    group by order_date;
    
    
    -- Write a query to show sales metrics by weekdays and weekends
    SELECT 
    CASE 
        WHEN DAYOFWEEK(order_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    ROUND(SUM(unit_price * order_quantity), 2) AS total_sales
FROM 
    grill_galaxy_sales
WHERE 
    MONTH(order_date) = 5  -- Filter for May
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(order_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END;

    
    -- show sales amount in thousands by different store locations
    SELECT 
    store_location,
    concat(round(SUM(unit_price * order_quantity)/1000), 'K') AS Total_Sales
FROM grill_galaxy_sales
WHERE
    MONTH(order_date) = 5 
GROUP BY store_location
ORDER BY SUM(unit_price * order_quantity) DESC;

    
-- Write a query to find out if the sales on a given day is above average or below average.
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(order_date) AS day_of_month,
        SUM(unit_price * order_quantity) AS total_sales,
        AVG(SUM(unit_price * order_quantity)) OVER () AS avg_sales
    FROM 
        grill_galaxy_sales
    WHERE 
        MONTH(order_date) = 5  -- Filter for May
    GROUP BY 
        DAY(order_date)
) AS sales_data
ORDER BY 
    day_of_month;
    
    
-- Find total sales amount by product categories.
SELECT 
    product_category,
    ROUND(SUM(unit_price * order_quantity), 1) as Total_Sales
FROM grill_galaxy_sales
WHERE
    MONTH(order_date) = 5 
GROUP BY product_category
ORDER BY SUM(unit_price * order_quantity) DESC;


-- Find Top 10 food items by their sales amount.
SELECT 
    product_type,
    ROUND(SUM(unit_price * order_quantity), 1) as Total_Sales
FROM grill_galaxy_sales
WHERE
    MONTH(order_date) = 5 
GROUP BY product_type
ORDER BY SUM(unit_price * order_quantity) DESC
LIMIT 10;


--  Write a query to return sales amount for a specific day and hour.
SELECT 
    ROUND(SUM(unit_price * order_quantity)) AS Total_Sales,
    SUM(order_quantity) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
    grill_galaxy_sales
WHERE 
    DAYOFWEEK(order_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    AND HOUR(order_time) = 8 -- Filter for hour number 8
    AND MONTH(order_date) = 5; -- Filter for May (month number 5)


-- Thank You Rest of findings and analysis of this project is done on power bi file, please refer to it.

















    
    
    

   
   
   






