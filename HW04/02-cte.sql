--------------------
-- cte
-- подзапрос - продажи сотрудников
SELECT P.PersonID, P.FullName, I.SalesCount
FROM Application.People AS P
JOIN (
	SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20140101' AND InvoiceDate < '20150101'
	GROUP BY SalespersonPersonID
	) AS I ON P.PersonID = I.SalespersonPersonID

-- cte (не забыть про ;)
-- имя InvoicesCTE [(список колонок)]
; WITH InvoicesCTE AS (
	SELECT SalespersonPersonID, Count(InvoiceId) as SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20140101' AND InvoiceDate < '20150101'
	GROUP BY SalespersonPersonID
	)
-- следующий оператор - обращение к cte
SELECT P.PersonID, P.FullName, I.SalesCount
FROM Application.People AS P
JOIN InvoicesCTE AS I ON P.PersonID = I.SalespersonPersonID


-- Несколько CTE
; with cte1(C) as (select 0 union all select 0) -- 2 rows
,cte2(C) as (select 0 from cte1 as T1 cross join cte1 as T2) -- 4 rows
,cte3(C) as (select 0 from cte2 as T1 cross join cte2 as T2) -- 16 rows
,cte4(C) as (select 0 from cte3 as T1 cross join cte3 as T2 cross join cte2 as T3) -- 1024 rows
--select count(*) from N4 as T1 cross join N4 -- 1,048,576 rows
select 1 + abs(checksum(newid())) % 100 from cte4 as T1 cross join cte4 -- рандом 1-100

--------------
-- обход некоторых ограничений
-- delete top N order by 
DROP TABLE IF EXISTS Sales.Invoices_DeleteDemo

SELECT TOP 300 *
INTO Sales.Invoices_DeleteDemo
FROM Sales.Invoices

-- нет сортировки
DELETE TOP (10) FROM Sales.Invoices_DeleteDemo ORDER BY InvoiceID
DELETE TOP (10) FROM Sales.Invoices_DeleteDemo
-- удалились не первые Ид
SELECT TOP 50 InvoiceId FROM Sales.Invoices_DeleteDemo ORDER BY InvoiceID

; WITH cte AS (
	SELECT TOP 10 InvoiceId
	FROM Sales.Invoices_DeleteDemo
	ORDER BY InvoiceID
	)
DELETE FROM cte

SELECT TOP 10 InvoiceId
FROM Sales.Invoices_DeleteDemo
ORDER BY InvoiceID


-----------------
-- рекурсия - обращение к результатам предыдущего шага
-- n! = 1 * 2 * 3... * n
-- цикл по i от 1 до @n, приращение на каждом шаге +1, переменная, для накопления результата - res
declare @n int = 5
declare @i int = 1, @res int = 1 -- начальные значения
while @i < @n begin
	set @i = @i + 1 
	set @res = @res * @i /*res из предыдущего шага * i из текущего шага*/

	print concat(@i, '! = ', @res)
end
go
-- цикл по i от 1 до @n, приращение на каждом шаге +1, переменная, для накопления результата - res
declare @n int = 5
; with cte as ( 
	select 1 as i, 1 as res -- начальные значения (якорь)
   	union all
   	select i + 1 as i, res * (i + 1) as res
	from cte /*обращение к строке, полученной на предыдущего шага*/ 
	where i < @n /*условие окончания цикла*/
)
select * from cte

-- сумма от 1 до m
declare @m int = 200 -- 1 + 2 + 3 + 4 + 5 ... + 200
; with cte as (
   	select 1 as i, 1 as res -- начальные значения (якорь)

   	union all

	-- доступна 1 строка, полученная на предыдущем шаге
   	select i + 1, res + (i + 1) 
	from cte /*обращение к строке, полученной на предыдущего шага*/ 
	where i < @m  /*условие окончания цикла*/
)
select * from cte option(maxrecursion 200)
	
-- как начать с 10?
-- как генерить только нечетные?


-----------------------------
--вывод структуры подчиненности
drop table if exists #Employees
create table #Employees (EmployeeID int primary key, FullName varchar(256), Title varchar(256), ManagerID int);

insert #Employees (EmployeeId, FullName, Title, ManagerID)
values (1, 'John Mann', 'CEO', NULL), (3, 'Abby Gold', 'HR', 1), (4, 'Mary Wang', 'HR', 3), (5, 'Jim Johnson', 'HR', 4), (6, 'Linda Smith', 'HR', 3), (7, 'Irvin Bow', 'CEO Deputy', 1), (8, 'Rob Walters', 'Worker', 6), (9, 'Dylan Miller', 'Worker', 8)
select * from #Employees

/*
кто кому подчиняется
John Mann - главный босс
	Abby Gold
		Mary Wang 
			Jim Johnson 	
		Linda Smith
			Rob	Walters
				Dylan Miller
	Irvin Bow
*/


; with cte as (
	-- anchor: главный босс (уровень 0)
	select EmployeeId, ManagerId
		, cast(FullName as varchar(1000)) as descr
		, 0 as level 
	from #Employees as em 
	where ManagerId is null

	union all 

	-- recursive part: подчинённые
	select em.EmployeeId, em.ManagerId
		, cast(FullName + '->' + descr as varchar(1000))
		, level + 1
	from cte as t -- обращение к результатам, полученным на предыдущем шаге
	inner join #Employees as em on em.ManagerId = t.EmployeeId -- запрос подчиненных
)
select * from cte as t --option(maxrecursion 4)