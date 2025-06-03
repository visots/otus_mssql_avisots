-- независимый
SELECT StockItemID, StockItemName, ( -- !! 1 строка и 1 колонка
									SELECT MAX(UnitPrice)
									FROM Warehouse.StockItems
									) AS MaxPrice
FROM Warehouse.StockItems

-- зависимый (коррелированный)
-- продажники и их продажи
SELECT PersonId, FullName, ( -- считаем продажи
							SELECT COUNT(InvoiceId) -- !! 1 строка и 1 колонка
							FROM Sales.Invoices
							WHERE Invoices.SalespersonPersonID = People.PersonID -- зависит от PersonID
							) AS TotalSalesCount
FROM Application.People
WHERE IsSalesperson = 1

-- то же самое только через join
SELECT 
	p.PersonId, 
	p.FullName, 
	count(*) as TotalSalesCount
FROM Application.People p
LEFT /*чтобы не потерять данные*/ JOIN Sales.Invoices i ON i.SalespersonPersonID = p.PersonID
WHERE p.IsSalesperson = 1
GROUP BY p.PersonID, p.FullName

-- ↑ какой эффективней?
----------

-- в подзапросе в SELECT мб только 1 строка!
SELECT PersonId, FullName, (
							SELECT InvoiceId -- ошибка
							FROM Sales.Invoices
							WHERE Invoices.SalespersonPersonID = People.PersonID
							) 
FROM Application.People
WHERE IsSalesperson = 1

----------------------------------
-- подзапросы в where: in, exists
----------------------------------
-- IN

-- Показать информацию по сотрудникам, которые к-л продавали товары
SELECT *
FROM Application.People
WHERE PersonId IN (SELECT SalespersonPersonID FROM Sales.Invoices); --in = список (1 колонка, несколько строк)

--то же самое
SELECT *
FROM Application.People
WHERE PersonId IN (SELECT distinct SalespersonPersonID FROM Sales.Invoices); 

-- то же самое
SELECT distinct p.*
FROM Application.People as p
inner join Sales.Invoices as i on i.SalespersonPersonID = p.PersonID

-------------
-- NULL
-- сколько строк получим?
SELECT *
FROM (
	select PersonId from Application.People 
	union all 
	select null -- добавлен NULL
) t
WHERE PersonId IN (1,2,NULL); -- =true











-- раскрываем скобки:
-- WHERE PersonId = 1 OR PersonID = 2 OR PersonId = NULL

-- обработка NULL
SELECT *
FROM (
	select PersonId from Application.People 
	union all 
	select null -- добавлен NULL
) t
WHERE PersonId IN (1,2) OR PersonId IS NULL

-- сколько строк получим?
SELECT *
FROM Application.People -- 1111 rows
WHERE PersonId NOT IN (1,2, NULL);











SELECT *
FROM Application.People
WHERE NOT (PersonId = 1 OR PersonID = 2 OR PersonId = NULL);
--WHERE PersonId != 1 AND PersonID != 2 and PersonId != NULL; --  PersonId != NULL для всх false
-- запросов с отрицанием лучше избегать - не самые оптимальные

----------------
-- EXISTS
----------------
SELECT *
FROM Application.People
WHERE PersonId IN (SELECT SalespersonPersonID FROM Sales.Invoices) 
ORDER BY PersonID;

SELECT *
FROM Application.People
WHERE EXISTS (
    SELECT *
	FROM Sales.Invoices
	WHERE SalespersonPersonID = People.PersonID) -- зависит от основной таблицы
ORDER BY PersonID;


-- Плохо ли здесь "SELECT *" ?
-- Не лучше ли "SELECT TOP 1 *" или "SELECT 1"?
-- посмотрим планы Ctrl + M
SELECT *
FROM Application.People
WHERE EXISTS (
    SELECT 1
	FROM Sales.Invoices
	WHERE SalespersonPersonID = People.PersonID)
ORDER BY PersonID;

SELECT DISTINCT Application.People.*
FROM Application.People
JOIN Sales.Invoices ON Invoices.SalespersonPersonID = People.PersonID
ORDER BY People.PersonID;

---------------------------
--- NOT EXISTS
SELECT *
FROM Application.People
WHERE NOT EXISTS ( 
    SELECT SalespersonPersonID
	FROM Sales.Invoices
	WHERE SalespersonPersonID = People.PersonID)




----------------
-- ALL (= любой из списка), ANY (= существует в списке)
----------------

-- Товары с минимальной ценой
-- минимальная цена
SELECT MIN(UnitPrice) FROM Warehouse.StockItems;

-- товары
SELECT StockItemID, StockItemName, UnitPrice 
FROM Warehouse.StockItems
WHERE UnitPrice <= ALL /*любой*/(SELECT UnitPrice FROM Warehouse.StockItems);

-- эквивалентно (работает быстрее)
SELECT StockItemID, StockItemName, UnitPrice 
FROM Warehouse.StockItems
WHERE UnitPrice = (SELECT min(UnitPrice) FROM Warehouse.StockItems);


-- IN, = ANY
SELECT StockItemID, StockItemName, UnitPrice	
FROM Warehouse.StockItems
WHERE UnitPrice IN /*существует*/ (SELECT UnitPrice FROM Warehouse.StockItems);

SELECT StockItemID, StockItemName, UnitPrice	
FROM Warehouse.StockItems
WHERE UnitPrice = ANY /*существует*/(SELECT UnitPrice FROM Warehouse.StockItems);