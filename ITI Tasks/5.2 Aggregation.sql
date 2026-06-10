-- [AdventureWorks2012]
--1
--Display the SalesOrderID, ShipDate of the SalesOrderHeader table (Sales schema)
--to show SalesOrders that occurred within the period ‘7/28/2002’ and ‘7/29/2014’ 
select SalesOrderID, ShipDate from Sales.SalesOrderHeader
where ShipDate between '7/28/2002' and '7/29/2014'

--2
--Display only Products(Production schema) with a StandardCost below $110.00 
--(show ProductID, Name only) 

select ProductID , Name from Production.Product
where StandardCost < 110

 
--3
--Display ProductID, Name if its weight is unknown 
select ProductID , Name from Production.Product
where Weight is not null
 
--4
--Display all Products with a Silver, Black, or Red Color
select  Name from Production.Product
where Color in ('Silver', 'Black', 'Red')

--5
--Display any Product with a Name starting with the letter B 
select  Name from Production.Product where name like 'B%'

--6
--Run the following Query Then write a query that displays any
--Product description with underscore value in its description. 

UPDATE Production.ProductDescription 
SET Description = 'Chromoly steel_High of defects' 
WHERE ProductDescriptionID = 3 

select Description from Production.ProductDescription
where Description like '%[_]%'


--7
--Calculate sum of TotalDue for each OrderDate in Sales.SalesOrderHeader table 
--for the period between  '7/1/2001' and '7/31/2014' 
select SUM(TotalDue), ShipDate from Sales.SalesOrderHeader
where ShipDate between '7/1/2001' and '7/31/2014' 
group by ShipDate
 

--8
--Display the Employees HireDate (note no repeated values are allowed) 
select distinct HireDate from [HumanResources].[Employee]

--9
--Calculate the average of the unique ListPrices in the Product table 
select distinct avg(ListPrice)from Production.Product

--10
--Display the Product Name and its ListPrice within the values 
--of 100 and 120 the list should has the following format 
--"The [product name] is only! [List price]" 
--(the list will be sorted according to its ListPrice value) 

select 'The ' + name + 'is only! '+ convert(varchar(20),ListPrice) as Product_price 
from Production.Product
where ListPrice between 100 and 120
order by ListPrice

--11
--a 
--Transfer the rowguid ,Name, SalesPersonID, Demographics 
--from Sales.Store table  in a newly created table named [store_Archive] 
--Note: Check your database to see the new table and how many rows in it? 
SELECT rowguid, Name, SalesPersonID, Demographics
INTO Sales.store_Archive
FROM Sales.Store;

select * from  Sales.store_Archive


--b
--Try the previous query but without transferring the data?  
SELECT rowguid, Name, SalesPersonID, Demographics
INTO Sales.store_Archive_
FROM Sales.Store
WHERE 1 = 0;

select * from  Sales.store_Archive_

--12
--Using union statement, retrieve the today’s date 
--in different styles using convert or format funtion. 
SELECT CONVERT(VARCHAR, GETDATE(), 101) AS TodayDateStyle -- mm/dd/yyyy
UNION
SELECT CONVERT(VARCHAR, GETDATE(), 103) -- dd/mm/yyyy
UNION
SELECT CONVERT(VARCHAR, GETDATE(), 104) -- dd.mm.yyyy
UNION
SELECT CONVERT(VARCHAR, GETDATE(), 120) -- yyyy-mm-dd hh:mi:ss
UNION
SELECT FORMAT(GETDATE(), 'dddd, MMMM dd, yyyy') -- e.g., Sunday, July 27, 2025
