/*

Supply Chain Analysis 

*/


----------------------------------------------------------------------------------------------------------------------------
--***CLEANING THE DATA***
----------------------------------------------------------------------------------------------------------------------------

--Cleaning Data in SQL Queries

SELECT *
FROM supplychainanalysis.dbo.US_Regional_Sales_Data

----------------------------------------------------------------------------------------------------------------------------
--Standardize Date Format

SELECT ProcuredDate, OrderDate, ShipDate, DeliveryDate, CONVERT(Date, ProcuredDate), CONVERT(Date, OrderDate), CONVERT(Date, ShipDate), CONVERT(Date, DeliveryDate)
FROM dbo.US_Regional_Sales_Data


UPDATE dbo.US_Regional_Sales_Data
SET ProcuredDate = CONVERT(Date, ProcuredDate), OrderDate = CONVERT(Date, OrderDate), ShipDate = CONVERT(Date, ShipDate), DeliveryDate = CONVERT(Date, DeliveryDate)


----------------------------------------------------------------------------------------------------------------------------
--Check for Null Values

--Using Boolean Then/Else to find any Null values in the table 
SELECT 
	sum(case when 1 is null then 1 else 0 end) as Column_1
	,sum(case when 2 is null then 1 else 0 end) as Column_2
	,sum(case when 3 is null then 1 else 0 end) as Column_3
	,sum(case when 4 is null then 1 else 0 end) as Column_4
	,sum(case when 5 is null then 1 else 0 end) as Column_5
	,sum(case when 6 is null then 1 else 0 end) as Column_6
	,sum(case when 7 is null then 1 else 0 end) as Column_7
	,sum(case when 8 is null then 1 else 0 end) as Column_8
	,sum(case when 9 is null then 1 else 0 end) as Column_9
	,sum(case when 10 is null then 1 else 0 end) as Column_10
	,sum(case when 11 is null then 1 else 0 end) as Column_11
	,sum(case when 12 is null then 1 else 0 end) as Column_12
	,sum(case when 13 is null then 1 else 0 end) as Column_13
	,sum(case when 14 is null then 1 else 0 end) as Column_14
	,sum(case when 15 is null then 1 else 0 end) as Column_15
	,sum(case when 16 is null then 1 else 0 end) as Column_16
FROM dbo.US_Regional_Sales_Data


----------------------------------------------------------------------------------------------------------------------------
--Updating Discount_Applied to a Percentage
--Note: When importing the CSV, the import wizard had Discount_Applied value as TIME. This needed to be changed to DECIMAL

UPDATE DBO.US_Regional_Sales_Data
SET Discount_Applied = (Discount_Applied * 100) 

--Now to remove the zeroes 
Alter table dbo.US_regional_sales_data alter column Discount_Applied int;

----------------------------------------------------------------------------------------------------------------------------


--Tables I want to query
--1. Total Sales by Sales Channel
-- First we need to add a column for total sales, alter the table to add column then update&set to update values in the new column
ALTER TABLE supplychainanalysis.dbo.US_Regional_Sales_Data  ADD Total_sales FLOAT 
UPDATE supplychainanalysis.dbo.US_Regional_Sales_Data 
SET Total_sales = (Order_Quantity * unit_price)


-- Now that we have total_sales we need to use SUM() and group by to combine values in each sales channel
SELECT Sales_Channel
	, sum(total_sales) as gross_sales
FROM supplychainanalysis.dbo.US_Regional_Sales_Data
GROUP BY Sales_Channel


--- Now query per sales channel per warehouse

SELECT Sales_Channel
	, WarehouseCode
	, sum(total_sales) as gross_sales
FROM supplychainanalysis.dbo.US_Regional_Sales_Data
GROUP BY WarehouseCode, Sales_Channel


-- Query total gross sales 

SELECT sum(total_sales) as gross_sales
FROM supplychainanalysis.dbo.US_Regional_Sales_Data

--2. Total Sales by Warehouse
--Same concepts as table 1
SELECT WarehouseCode
	, sum(total_sales) as gross_sales
FROM supplychainanalysis.dbo.US_Regional_Sales_Data
GROUP BY WarehouseCode


--3. Average Delivery Time by Sales Channel
-- same as above, alter table to add column and update&set to update values
-- in this case we need to use datediff to calculate the delivery time in DAYS
ALTER TABLE supplychainanalysis.dbo.US_Regional_Sales_Data  ADD Delivery_Time FLOAT 
UPDATE supplychainanalysis.dbo.US_Regional_Sales_Data 
SET Delivery_Time = datediff(DAY, orderdate, deliverydate)

-- Now to query for average transit as a new column 
SELECT Sales_channel
	, avg(Delivery_time) as Average_Transit
FROM supplychainanalysis.dbo.US_Regional_Sales_Data
GROUP BY sales_channel


--Possible Recommendations based on analysis
--Created a customized pricing structure for different sales channels by factoring in variables like order size, volume and frequency. Implement customer retention programs such as a loyalty system or discount campaigns.
--Optimize the supply chain management system to streamline operations and mitigate any potential disruptions that might impact wholesale customers.
--Utilize an innovative approach to increase customer experience across all sales channels that ensures a uniform pricing structure. Provide promotional offerings through discounts and loyalty incentives.

/* 

Inventory Analysis

*/

--4. Total Sales by Product ID and Sales Channel
SELECT ProductID
	, Sales_Channel
	, sum(total_sales) as gross_sales
FROM supplychainanalysis.dbo.US_Regional_Sales_Data
group by ProductID, Sales_Channel


--5. Top 10 Products by Sales
SELECT TOP 10 ProductID
	, sum(total_sales) as gross_sales
FROM supplychainanalysis.dbo.US_Regional_Sales_Data
Group By ProductID
Order by gross_sales DESC


--6. Analyze inventory turnover and identify slow moving products
-- First alter table to add new column Turnover_time then update&set to input value for new column
ALTER TABLE supplychainanalysis.dbo.US_Regional_Sales_Data  ADD Turnover_Time FLOAT 
UPDATE supplychainanalysis.dbo.US_Regional_Sales_Data 
SET Turnover_time = abs(datediff(DAY, ProcuredDate, ShipDate))


select ProductID, avg(Turnover_time) as Average_turnover_in_days
FROM SupplyChainAnalysis.dbo.US_Regional_Sales_Data
Group By ProductID 
Order by ProductID


--7. Cost Analysis

ALTER TABLE supplychainanalysis.dbo.US_Regional_Sales_Data  ADD Total_cost INT
UPDATE supplychainanalysis.dbo.US_Regional_Sales_Data
SET Total_cost = Order_Quantity * Unit_Cost
ALTER TABLE supplychainanalysis.dbo.US_Regional_Sales_Data  ADD Total_profit INT
UPDATE supplychainanalysis.dbo.US_Regional_Sales_Data
SET Total_profit = Order_Quantity * Unit_Price


select ProductID
	, sum(total_cost) as Gross_cost
	, sum(total_profit) as Gross_profit
	, sum(total_profit) - sum(total_cost) as Net_Profit
	, ((sum(total_profit) - sum(total_cost)) / (cast(sum(total_profit) as decimal(10,2))) * 100) AS Net_Profit
FROM SupplyChainAnalysis.dbo.US_Regional_Sales_Data
Group by ProductID


--Possible Recommendations based on analysis
--Optimize inventory storage to highlight products with an above average shelf time and implement a promotional campaign or discount program that incentives the purchase of stagnant products. Since net profit percentage is ~38% across all products an decrease turnover time will benefit all sales channels.
--Create marketing campaigns or promotions targeting in store customers with the goal of increasing gross sales through possible conversion of online customers and upselling. This can be accomplished by in store only promotions and efficient product placement
--Utilize advanced data collection and analytics to take a deep dive into the top ten grossing products and further understand what is causing the increased sales.

