/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

--Подзапрос
SELECT PersonID, FullName 
FROM Application.People 
WHERE IsSalesperson = 1 AND PersonId NOT IN (SELECT SalespersonPersonID 
											 FROM Sales.Invoices 
											 WHERE InvoiceDate ='2015-07-04' )
--СTE
;WITH inv AS (
	SELECT SalespersonPersonID 
	FROM Sales.Invoices 
	WHERE InvoiceDate ='2015-07-04' )
SELECT PersonId, FullName 
FROM Application.People p
LEFT JOIN inv as i on i.SalespersonPersonID = p.PersonID 
WHERE p.IsSalesperson = 1 and i.SalespersonPersonID IS NULL

--Проверка
--select PersonID From Application.People where IsSalesperson = 1--Продажники
--Except
--select distinct SalespersonPersonID from Sales.Invoices
--where InvoiceDate ='2015-07-04' --Те кто сделал продажи 2015-07-04


/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/
SELECT [StockItemId], 
	   [StockItemName],
	   [UnitPrice]
FROM [Warehouse].[StockItems] s 
JOIN ( select Min(UnitPrice) as  MinPrice from [Warehouse].[StockItems]) m on s.UnitPrice = m.MinPrice

SELECT [StockItemId], 
	   [StockItemName],
	   [UnitPrice]
FROM [Warehouse].[StockItems] 
WHERE UnitPrice = ( 
						SELECT MIN(UnitPrice)
						FROM [Warehouse].[StockItems]
					 )

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

select ct.CustomerID, c.CustomerName 
from [Sales].[CustomerTransactions] ct
join [Sales].[Customers] c on c.CustomerID = ct.CustomerID
where CustomerTransactionID in
		(select  top 5 CustomerTransactionID from [Sales].[CustomerTransactions]
		order by TransactionAmount desc)

select t.CustomerID, c.CustomerName 
from  (select  top 5 CustomerTransactionID, CustomerID from [Sales].[CustomerTransactions]
		order by TransactionAmount desc) as t
join [Sales].[Customers] c on c.CustomerID = t.CustomerID

;with cte as (
	select  top 5 CustomerTransactionID, CustomerID 
	from [Sales].[CustomerTransactions]	
	order by TransactionAmount desc
)
select c.CustomerID, c.CustomerName 
from [Sales].[Customers] c
join cte  on cte.CustomerID=c.CustomerID



/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

; with Top3PriceItemOrders as (
 select distinct OrderID from [Sales].[OrderLines]
 where StockItemID in ( select top 3 StockItemID
					    from [Warehouse].[StockItems] 
					    order by UnitPrice desc
					  )
 )
 SELECT distinct ct.CityID, ct.CityName, p.FullName
  FROM [WideWorldImporters].[Sales].[Orders] o
  join [Sales].[Customers] c on c.CustomerID = o.CustomerID
  join [Application].[People] p on p.PersonID = o.PickedByPersonID
  join [Application].[Cities] ct on ct.CityId = c.DeliveryCityId
  join Top3PriceItemOrders t on t.OrderID =o.OrderID
  where o.PickedByPersonID is not null

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

TODO: напишите здесь свое решение
