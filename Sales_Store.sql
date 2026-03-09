CREATE TABLE Sales_store (
    transaction_id VARCHAR(15),
    customer_id VARCHAR(15),
    customer_name VARCHAR(30),
    customer_age INT,
    gender VARCHAR(15),
    product_id VARCHAR(15),
    product_name VARCHAR(15),
    product_category VARCHAR(15),
    quantiy INT,
    prce FLOAT,
    payment_mode VARCHAR(15),
    purchase_date DATE,
    time_of_purchase TIME,
    status VARCHAR(15)
); 

 SELECT * FROM Sales_store;
 Set DATEFORMAT dmy
 BULK INSERT Sales_store 

 from 'C:\Users\PC\Music\Pizza_sales\pizza_sales\sale.csv'

 With (
  FirstRow = 2 ,
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n'
  );

  -- create Copy of the Data SET or Table 

  Select * from Sales_store;

  Select * INTO Sales From Sales_store; -- it is copy of the Data 

  Select * from Sales;

  -- Data Cleaning 

  -- Step 1 :- To check Duplicates 

  Select transaction_id ,count(*) from Sales
  Group by transaction_id
  Having COUNT(transaction_id) > 1;

TXN240646
TXN342128
TXN855235
TXN981773



With CTE AS (Select *, 
ROW_NUMBER() OVER (Partition by transaction_id order by transaction_id) AS row_num
 From Sales
 )

-- Delete from CTE 
 --Where row_num =2 ;


 select * from CTE 
 WHERE transaction_id  IN(
'TXN240646',
'TXN342128',
'TXN855235',
'TXN981773'
) ;

-- Step 2:- correction of the Headers 
select * from Sales ;

Exec sp_rename'Sales.quantiy', 'quantity','COLUMN'

Exec sp_rename'Sales.prce', 'price','COLUMN'

-- Step 3:- To check Data Type 
Select Column_Name , DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
Where TABLE_NAME = 'Sales';

-- Step 4:- To checl Null values 

DECLARE @SQL NVARCHAR(MAX) = '';

Select @SQL = STRING_AGG(
'SELECT ''' + COLUMN_NAME +''' AS ColumnNName,
count(*) AS NullCount
FROM' + QUOTENAME(TABLE_SCHEMA)+ '.sales
WHERE' QUOTENAME(COLUMN_NAME) + 'IS NULL',
'UNION ALL '
) 
within Group (order by COLUMN_NAME)
 FROM INFORMATION_SCHEMA.COLUMNS
Where TABLE_NAME = 'Sales';

-- Excute Dyanamic Sql 

Exce sp_excutesql @sql ;

-- TREAT NULL VALUES 

select * from sales 
where transaction_id is null 
or 
customer_id is null 
or
customer_name is NULL 
or
customer_age is null 
or
gender is null 
or 
PRODUCT_id is null 
or 
product_name is null 
or 
product_category is null 
or 
quantity is null 
or 
price is null 
or 
payment_mode is null 
or 
purchase_date is null 
or 
time_of_purchase is null 
or 
status is null ;

select * from Sales ;

delete from sales 
where transaction_id is null 

select * from Sales 
where  customer_Name = 'Ehsaan Ram';




update sales 
set  customer_id = 'CUST9494'
where transaction_id = 'TXN977900'

select * from Sales 
where  customer_Name = 'Damini Raju';

update sales 
set  customer_id = 'CUST1401'
where transaction_id = 'TXN985663'

select * from Sales 
where  customer_id= 'CUST1003';

update sales 
set  customer_name = 'Mahika Saini', customer_age ='35', gender ='Male'
where transaction_id = 'TXN432798';

-- step 5 :_ data cleaning 

select distinct  gender from Sales;

update sales 
set gender = 'F'
where gender = 'Female';

update sales 
set gender = 'M'
where gender = 'Male';

select Distinct payment_mode from sales ;

update sales 
set Payment_mode ='Credit Card'
where Payment_mode = 'CC';

-- Data Analysis 

-- what are the TOP 5 most Selling product by quantity 

select distinct status from sales ;

select top 5 product_name , sum(quantity) AS Total_quantity
from Sales 
where status = 'delivered'
group by product_name
order by Total_quantity desc ;

-- Business problem we don't know which product are in  most demand
-- Business impact :- Help to prioritize  stock and bost the sales through targeted promotion 

-----------------------------------------------------------------------------------------------------------

-- 2 which product are most frequently cancelled ?


select top 5 product_name , count(*) AS Total_Cancelled
from Sales 
where status = 'cancelled'
group by product_name
order by Total_Cancelled desc ;

-- Business problem :- Frequently cancellation effect revenue and customer trust 
-- Business Impact :- identitfy poor-performance  product to improve quality or remove from catlog.

-----------------------------------------------------------------------------------------------------------

-- 3 what timne of the day higest number of purcahse 

select * from sales ;

select 
case
when  DATEPART(Hour, time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
when  DATEPART(Hour, time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
when  DATEPART(Hour, time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
when  DATEPART(Hour, time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'

END AS time_of_day,
count(*) as total_order
from sales
group by 
case
when  DATEPART(Hour, time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
when  DATEPART(Hour, time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
when  DATEPART(Hour, time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
when  DATEPART(Hour, time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
END 
order by total_order desc ;

-- Busines problem solved :- Find the peak sales Times 
-- Business impact :- optimizing Staffing , promotion and server load 
----------------------------------------------------------------------------------

-- 4 )who are top 5 highest spending customers ?
select top 5  customer_name , 
 Format(sum(price*quantity),'C0','en-IN')AS total_spend 
from Sales 
group by customer_name
order by sum(price*quantity) desc ;

-- Business problem solved :- Identitfy VIP Customer 
-- Business impact :- personalized offers, loyalty rewards, and retention 

-------------------------------------------------------------------------------------------

--5 ) which category genrate  the Highest revenue 

select * from sales ;

select product_category ,
Format(sum(price * quantity ), 'C0','en-IN') AS Revenue 
 from Sales 
 group by product_category
 order by sum(price * quantity ) desc ;

 -- Busniess problem solved :- identify top performing product category 
 -- Business impact Refine product strategey , suypply chain ,and promotions
 -- allowing bsuiness to invest more high margin or high demant categories 
 

 -- What is the return / cancelation rate per product category ?

select * from sales ;
-- cancelation 
select product_category,
format(count(CASE WHEN status = 'cancelled' then 1 END )* 100.0 /COUNT(*), 'N3') + ' %'AS cancel_percent
from sales 
group by product_category
order by cancel_percent desc ;

-- return 
select * from Sales ;

select product_category,
format(count(CASE WHEN status = 'returned' then 1 END )* 100.0 /COUNT(*), 'N3') + ' %'AS returned_percent
from sales 
group by product_category
order by returned_percent desc ;

-- Busines problem :- Monitor disstaisfaction trends per category 
-- Business Impact :- reduce return improve product description / expectations 
-- Help identifying and fix product or logistic issue 
-------------------------------------------------------------------------------------------------

-- 7 what is the most  prefered Payment mode 

select * from sales ;

select payment_mode , count(payment_mode) AS total_count
from Sales 
group by payment_mode
order by total_count desc ;


-- Business problem :- Knows which payment option customer preffered 
-- Business impact :- stream line payment processing , prioritize popular paymnet mode 

------------------------------------------------------------------------------------------------------
-- 8 ) how does the Age group effect purcahse Behaviour 
select * from sales ;


select 
Case 
When customer_age BETWEEN 18 AND 25 THEN '18-25'
When customer_age BETWEEN 26 AND 35 THEN '26-35'
When customer_age BETWEEN 36 AND 50 THEN '36-50'
Else '51+'
END AS Customer_age  ,
Format(sum(price * quantity),'C0','en-IN') AS total_purcahse 

from Sales 

group by 
Case 
When customer_age BETWEEN 18 AND 25 THEN '18-25'
When customer_age BETWEEN 26 AND 35 THEN '26-35'
When customer_age BETWEEN 36 AND 50 THEN '36-50'
Else '51+'
END
order by total_purcahse desc ;

-- Business problem :- Identify to understand customer demographics 
-- Business Impact :- Target , marketing and product recomendation by age group 

-- -----------------------------------------------------------------------------------------------
-- 9 ) What is monthly Sales Trend 

select * from sales ;

Select 
FORMAT (purchase_date , 'yyyy-MM') AS Montly_Sale ,
 FORMAT(Sum(price*quantity),'C0','en-IN') AS Total_sales ,
Sum(quantity) AS Total_quantity 
from Sales 
group by FORMAT (purchase_date , 'yyyy-MM') ;

-- Second method 

select 
 
Month(Purchase_date) AS Month ,
FORMAT(Sum(price*quantity),'C0','en-IN') AS Total_sales ,
Sum(quantity) AS Total_quantity 
from sales 
group by Month(Purchase_date)
order by Month ; 

-- Busines problem :- Sales Flacutaions go unnoticed 
-- Business Impact :- Plan inventory and marketing ccording to the sessional trends 

-------------------------------------------------------------------------------------------------
-- ARE certain gender buying more specific category 

select *  from sales; 

select gender , product_category , count(product_category) AS total_purchase 
from Sales 
group by gender , product_category
order by gender  desc ;

-- Method 2 
select * from sales ;

select * from (
select gender , product_category 
from sales 
) AS source_table 
pivot (
count(gender)
for gender IN ([M],[F]) 
) AS pivot_table
order by product_category; 

-- Business problem - Gender based product prefrenced 
-- Business Impact :- personalised ads , gender focused campaigns 