-- Create a new database called 'learn_corhort'
-- Connect to the 'master' database to run this snippet
USE master
GO
-- Create the new database if it does not exist already
IF NOT EXISTS (
    SELECT name
        FROM sys.databases
        WHERE name = N'learn_corhort'
)
CREATE DATABASE learn_corhort
GO

USE learn_corhort

WITH t0 AS (
    SELECT * FROM Superstore
    WHERE LEFT(Order_Date, 4) = '2016'
)
, t1 AS (
    SELECT Order_ID, Order_Date, Customer_ID, Sales, FORMAT(Order_Date, 'yyyy-MM-01') AS order_month
    FROM t0
)

-- Get Frist Date Order By Customer
, get_first_date_order AS (
    SELECT Customer_ID
    , FORMAT(MIN(Order_Date), 'yyyy-MM-01') AS corhort_month
    FROM t1
    GROUP BY Customer_ID
)

-- Get Cohort Index By Using DateDiff
, get_corhort_index AS (
    SELECT 
    t.Customer_ID
    , t.Sales
    , t.Order_Date
    , t.order_month
    , g.corhort_month
    , DATEDIFF(MONTH,CAST(g.corhort_month AS date), CAST(t.order_month AS date)) + 1  AS corhort_index 
    FROM t1 t
    JOIN get_first_date_order g
    ON t.Customer_ID = g.Customer_ID
)

-- Get Table With Count Distinct Customer And Group By ...
, count_cust_table AS (
    SELECT corhort_month, corhort_index, COUNT(distinct Customer_ID) AS count_cust
    FROM get_corhort_index
    GROUP BY corhort_month, corhort_index
)
, data_pitab_sales AS (
    SELECT corhort_month, corhort_index, SUM(Sales) AS total_sales
    FROM get_corhort_index
    GROUP BY corhort_month, corhort_index
)
-- Pivot Table by sales
, get_pitab_sales AS (
    SELECT * 
    FROM
        (
            SELECT corhort_month, corhort_index, total_sales
            FROM data_pitab_sales
        ) t1
    PIVOT
        (
            SUM(total_sales)
            FOR corhort_index IN ( [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12] )
        ) pi
)
-- Pivot Table by count distinct customer
, get_pitab_count_customer AS (
    SELECT * 
    FROM
        (
            SELECT corhort_month, corhort_index, count_cust
            FROM count_cust_table
        ) t1
    PIVOT
        (
            SUM(count_cust)
            FOR corhort_index IN ( [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12] )
        ) pi
)

-- Pivot Table by count distinct customer visual %
, get_tab_total_customer_by_percent AS (
    SELECT * 
    FROM
        (
            SELECT corhort_month
            , ROUND(1.0 * [1]/[1], 2) AS [1]
            , ROUND(1.0 * [2]/[1], 2) AS [2]
            , ROUND(1.0 * [3]/[1], 2) AS [3]
            , ROUND(1.0 * [4]/[1], 2) AS [4]
            , ROUND(1.0 * [5]/[1], 2) AS [5]
            , ROUND(1.0 * [6]/[1], 2) AS [6]
            , ROUND(1.0 * [7]/[1], 2) AS [7]
            , ROUND(1.0 * [8]/[1], 2) AS [8]
            , ROUND(1.0 * [9]/[1], 2) AS [9]
            , ROUND(1.0 * [10]/[1], 2) AS [10]
            , ROUND(1.0 * [11]/[1], 2) AS [11]
            , ROUND(1.0 * [12]/[1], 2) AS [12]
            FROM get_pitab_count_customer
        ) table_visual_percent
)

--SELECT * FROM count_cust_table 
-- Got by Google Bard
SELECT
  cohort_month,
  COUNT(*) AS number_of_customers,
  COUNT(DISTINCT Customer_ID) AS number_of_unique_customers,
  (COUNT(*) / COUNT(DISTINCT Customer_ID)) AS retention_rate
FROM
  (
    SELECT 
    t.Customer_ID
    , t.Sales
    , t.Order_Date
    , t.order_month
    , g.corhort_month
    , DATEDIFF(MONTH,CAST(g.corhort_month AS date), CAST(t.order_month AS date)) + 1  AS cohort_month 
    FROM t1 t
    JOIN get_first_date_order g
    ON t.Customer_ID = g.Customer_ID
  ) AS cohort
GROUP BY
  cohort_month
ORDER BY
  cohort_month;
       