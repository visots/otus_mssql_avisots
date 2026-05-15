-- Ctrl + M
use WideWorldImporters
----------------------
-- чтение
----------------------
-- columnstore ix scan 
select StockItemID, UnitPrice from Sales.InvoiceLines where UnitPrice > 300

-- vs cl ix scan
select StockItemID, UnitPrice from Sales.InvoiceLines with (index=1) where UnitPrice > 300

----------------------
-- соединение
----------------------

----------------------
-- группировка: stream aggregate vs hash match (aggregate)
--	group by/agg func/distinct
----------------------
-- 1. stream aggregate: sorted input: ix FK_Sales_InvoiceLines_PackageTypeID 
select PackageTypeID, count(*)
from Sales.InvoiceLines
group by PackageTypeID

-- extra: distinct == group by
select distinct PackageTypeID 
from Sales.InvoiceLines

-- 2. hach match (aggregate): unsorted input + many rows
-- индекс есть, но дочитываем UnitPrice => pk_ => неотсортированный по PackageTypeID вход
select PackageTypeID, avg(UnitPrice)
from Sales.InvoiceLines
group by PackageTypeID


-- columnstore => hach match (aggregate)
SELECT StockItemID, MAX(UnitPrice), SUM(UnitPrice)
FROM Sales.InvoiceLines 
WHERE InvoiceID > 600
GROUP BY StockItemID
--having SUM(UnitPrice) > 10000 -- Filter

-- Note: less groups -> better results
SELECT MAX(UnitPrice), SUM(UnitPrice)
FROM Sales.InvoiceLines 
WHERE InvoiceID > 600

---
-- 3. column store => window agg ->  temp db
SELECT SUM(UnitPrice) OVER ()
FROM Sales.InvoiceLines 
WHERE InvoiceID > 600 
-- а как исправить?

--windows agg normal
SELECT SUM(UnitPrice) OVER (), UnitPrice, InvoiceID
FROM Sales.InvoiceLines 
WHERE InvoiceID < 600

-- windows agg + sort (because partition by InvoiceID)
SELECT SUM(UnitPrice) OVER (partition by InvoiceID), UnitPrice, InvoiceID
FROM Sales.InvoiceLines 
WHERE InvoiceID < 600

-- stream agg (no columnstore index)
SELECT COUNT(*) OVER (PARTITION BY InvoiceDate), InvoiceDate, InvoiceID
FROM Sales.Invoices 
WHERE InvoiceID < 600
----------------------
-- performance: spools, parallelism, bitmap filter
----------------------
--bitmap, lazy spool, segment... 
SELECT Invoices.InvoiceId, Invoices.InvoiceDate, Invoices.CustomerID
	, MAX(trans.TransactionAmount) OVER (PARTITION BY /*=group by => sort + segment */ trans.CustomerId) AS MaxPerCustomer
FROM Sales.Invoices AS Invoices /*ix scan*/
JOIN Sales.CustomerTransactions AS trans /*ix scan*/ ON Invoices.InvoiceID = trans.InvoiceID /* join */
WHERE Invoices.InvoiceDate < '2014-01-01'
ORDER BY Invoices.InvoiceId, Invoices.InvoiceDate
option (maxdop 1)

--assert
DROP TABLE IF EXISTS Genders 
GO
CREATE TABLE Genders(ID Integer, Gender CHAR(1))  
GO
ALTER TABLE Genders ADD CONSTRAINT ck_Gender_M_F CHECK(Gender IN ('M','F'))  
GO
INSERT INTO Genders (ID, Gender) VALUES(1,'F') 
GO
DROP TABLE IF EXISTS Genders 

-----------------
-- некоторые функции
-- CASE, CHOOSE, IIF
SELECT TOP 40 PersonId, isSalesPerson
-- мало условий -> можно переписать через iif
	, CASE isSalesPerson 
		WHEN 1 THEN 'Yes'
		WHEN 0 THEN 'No'
		ELSE 'Hmm'
		END AS [WorksInSales?]
	, iif(isSalesPerson = 1, 'Yes', iif(isSalesPerson = 0, 'No', 'Hmm')) AS [WorksInSales1?]
--	
	, Emailaddress, OtherLanguages, LogonName
	, CASE -- смотрим результат (срабатывает первое совпадение по условию)
		WHEN Emailaddress LIKE '%@wideworldimporters.com'THEN 'WWI'
		WHEN Emailaddress LIKE '%@nodpublishers.com'THEN 'NOD'
		WHEN OtherLanguages LIKE '%Polish%' THEN '!!' --сюда не попадем, хотя ["Polish","Chinese","Japanese"]
		WHEN LogonName = 'NO LOGON'AND IsPermittedToLogon = 0 THEN 'No way'
		ELSE 'Hmm'
		END AS Nickname
	-- возвращет значение, которое находится на указанном месте
	-- PersonId = 1 -> 'One' ... PersonId = 5 -> null
	, choose(PersonId, 'One', 'Two', 'Three', 'Four') AS ID1234
FROM Application.People
ORDER BY PersonId


-- cast and convert
-- TRY_CONVERT
select top 10
    PersonId   
	, iif(PersonId < 5
		, choose (PersonId,'One','Two','Three','Four')
		, convert(varchar(10),PersonID)
		) as ID1234Plus
	-- не то же самое!
	, try_convert(int, 
		choose (PersonId,'One','Two','Three','Four')
		) as ID1234Conv
from Application.People
order by PersonId

 
-- STRING_SPLIT 
-- for data generation 
-- 50000 rows
select row_number() over(order by 1/0) as rn  
from string_split(space(999), ' ') t1, string_split(space(49), ' ') 


-- cross join 
;with cte_mm as (select row_number() over(order by 1/0) as mm from string_split(space(11), ' '))
	, cte_yy as (select value as yy from string_split('2013 2014 2015 2016', ' '))
select * from cte_yy,  cte_mm 
