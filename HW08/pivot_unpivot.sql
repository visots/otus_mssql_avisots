use WideWorldImporters;

-- 1 строка с итогами
SELECT * 
FROM ( 
	select YEAR(ord.OrderDate) as SalesYear
		, L.UnitPrice * L.Quantity as TotalSales
	from Sales.Orders as ord
	join Sales.OrderLines L on ord.OrderID = L.OrderID
	join Sales.Customers as c on c.CustomerID = ord.CustomerID 
	) as t
-- перед pivot должны остаться только используемые колонки 
-- по колонкам, не задействованным в pivot, выполняется неявная группировка	
-- до pivot 2 колонки => результат - 1 строка
PIVOT (
	sum(TotalSales) -- агрегирующая ф-ция
	for SalesYear in ([2013],[2014],[2015],[2016]) -- колонки "для разворота"
	) as pvt

-- НЕЯВНАЯ (не пишем group by) группировка по клиентам
SELECT * 
FROM (
	SELECT c.CustomerName -- доп колонка
		, YEAR(ord.OrderDate) AS SalesYear
		, L.UnitPrice * L.Quantity AS TotalSales
	FROM Sales.Orders AS ord
	JOIN Sales.OrderLines L ON ord.OrderID = L.OrderID
	JOIN Sales.Customers as c on c.CustomerID = ord.CustomerID 
	) as t
PIVOT (
	sum(TotalSales) 
	for SalesYear IN ([2013],[2014],[2015],[2016]) 
	) as pvt
order by CustomerName


SELECT SalesYear, 
       ISNULL([Q1], 0) AS Q1, 
       ISNULL([Q2], 0) AS Q2, 
       ISNULL([Q3], 0) AS Q3, 
       ISNULL([Q4], 0) AS Q4, 
       (ISNULL([Q1], 0) + ISNULL([Q2], 0) + ISNULL([Q3], 0) + ISNULL([Q4], 0)) SalesYTD
FROM
(
    SELECT YEAR(OH.OrderDate) AS SalesYear, 
           CAST('Q'+CAST(DATEPART(QUARTER, OH.OrderDate) AS VARCHAR(1)) AS VARCHAR(2)) AS Quarters, 
           SUM(L.UnitPrice*L.Quantity) AS TotalSales
    FROM Sales.Orders OH
    JOIN Sales.OrderLines L ON OH.OrderId = L.OrderId
	GROUP BY YEAR(OH.OrderDate), 
           CAST('Q'+CAST(DATEPART(QUARTER, OH.OrderDate) AS VARCHAR(1)) AS VARCHAR(2))
 ) t
 PIVOT(
	SUM(TotalSales) 
	FOR Quarters IN ([Q1], [Q2], [Q3], [Q4])
	) AS pvt
ORDER BY SalesYear

--- error
SELECT * 
FROM (
	SELECT YEAR(ord.OrderDate) AS SalesYear
		,L.UnitPrice * L.Quantity AS TotalSales
	FROM Sales.Orders AS ord
	JOIN Sales.OrderLines L ON ord.OrderID = L.OrderID
) t 
PIVOT (
	SUM(TotalSales), AVG(TotalSales) -- <-- 2 агрегирующие функции!!
	FOR SalesYear IN ([2013],[2014],[2015],[2016])
	) as PVT

-- перепишем
; with cte as (
	SELECT YEAR(ord.OrderDate) AS SalesYear
		,L.UnitPrice * L.Quantity AS TotalSales
	FROM Sales.Orders AS ord
	JOIN Sales.OrderLines L ON ord.OrderID = L.OrderID
)
, cte1 as (
	select * from cte
	pivot (
		sum(TotalSales)
		for SalesYear IN ([2013],[2014],[2015],[2016])
	) pvt
)
, cte2 as (
	select * from cte 
	pivot (
		avg(TotalSales)
		for SalesYear IN ([2013],[2014],[2015],[2016])
	) pvt
)
select t1.*
	, t2.[2013] as [avg 2013], t2.[2014] as [avg 2014], t2.[2015] as [avg 2015], t2.[2016] as [avg 2016]
from cte1 as t1, cte2 as t2

-- вариант 2
; with cte as (
	SELECT YEAR(ord.OrderDate) AS SalesYear
		,L.UnitPrice * L.Quantity AS TotalSales
	FROM Sales.Orders AS ord
	JOIN Sales.OrderLines L ON ord.OrderID = L.OrderID
)
select sum([2013]) as [2013], sum([2014]), sum([2015]), sum([2016])
	, avg([2013]) as [avg 2013], avg([2014]), avg([2015]), avg([2016])
from (
	select [2013] = case SalesYear when 2013 then TotalSales end
		, [2014] = case SalesYear when 2014 then TotalSales end
		, [2015] = case SalesYear when 2015 then TotalSales end
		, [2016] = case SalesYear when 2016 then TotalSales end
	from cte 
) t 

--- unpivot
-- pivot сохраним  в #t 
drop table if exists #t 

SELECT * 
into #t 
FROM ( 
	select YEAR(ord.OrderDate) as SalesYear
		, L.UnitPrice * L.Quantity as TotalSales
	from Sales.Orders as ord
	join Sales.OrderLines L on ord.OrderID = L.OrderID
	join Sales.Customers as c on c.CustomerID = ord.CustomerID 
	) as t
PIVOT (
	sum(TotalSales) -- агрегирующая ф-ция
	for SalesYear in ([2013],[2014],[2015],[2016]) -- колонки "для разворота"
	) as pvt

select * from #t 
SELECT *
FROM (-- то, что получили до этого в pivot (1 строка, 4 колонки)
	select [2013],[2014],[2015],[2016] 
	from #t
	) t 
UNPIVOT( -- 2 колонки, 4 строки (=кол-ву значений в IN ())
		-- TotalSales - произвольное название для колонки с данными из таблицы
		TotalSales
		-- SalesYear - произвольное название для колонки с описанием
		for SalesYear IN ([2013],[2014],[2015],[2016])
) AS upvt

--- 4 столбца - в строки (удобнее искать по одной колонке)
SELECT PersonID, FullName, PreferredName, LogonName
FROM Application.People

-- null - исключен: PersonId <= 2 - по 2 строки на id, далее - по 3
SELECT *
FROM (
	SELECT PersonID, FullName, PreferredName, iif(PersonId <= 2, null, LogonName) as LogonName
	FROM Application.People
	) AS People
UNPIVOT ( -- PersonID - не вошло в unpivot => перешло в итоговую таблицу
	PersonName -- колонка с данными из таблицы
	FOR Name IN (FullName, PreferredName, LogonName) -- колонка с описанием 
) AS unpt

