/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT [StockItemID]
      ,[StockItemName]
FROM [Warehouse].[StockItems]
WHERE  StockItemName like '%urgent%' OR StockItemName like 'Animal%'


/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT s.SupplierID, s.SupplierName FROM [Purchasing].[Suppliers] s
LEFT JOIN [Purchasing].[PurchaseOrders] po on po.SupplierID = s.SupplierID
WHERE po.SupplierID is null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

SELECT o.OrderId,
	   FORMAT(o.OrderDate,'dd.MM.yyyy') as OrderDate,
	   DATENAME(m,o.OrderDate) as [MonthName],
	   DATEPART(q,o.OrderDate) as [Quarter],
	   CEILING(DATEPART(MONTH,o.OrderDate)/4.0) as ThirdOfYear,
	   c.CustomerName
  FROM [Sales].[Orders] o
  join [Sales].[OrderLines] ol on ol.OrderID = o.OrderID
  join [Sales].[Customers] c on c.CustomerID = o.CustomerID
  where (ol.UnitPrice > 100.0 or ol.Quantity >20) and  ol.PickingCompletedWhen is not null
  order by [Quarter],[ThirdOfYear], o.OrderDate asc

--Pagination
SELECT o.OrderId,
	   FORMAT(o.OrderDate,'dd.MM.yyyy') as OrderDate,
	   DATENAME(m,o.OrderDate) as [MonthName],
	   DATEPART(q,o.OrderDate) as [Quarter],
	   CEILING(DATEPART(MONTH,o.OrderDate)/4.0) as ThirdOfYear,
	   c.CustomerName
  FROM [Sales].[Orders] o
  join [Sales].[OrderLines] ol on ol.OrderID = o.OrderID
  join [Sales].[Customers] c on c.CustomerID = o.CustomerID
  where (ol.UnitPrice > 100.0 or ol.Quantity >20) and  ol.PickingCompletedWhen is not null
  order by [Quarter],[ThirdOfYear], o.OrderDate asc
  offset 1000 rows
  fetch next 100 rows only

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

select 
dm.DeliveryMethodName,
po.ExpectedDeliveryDate,
s.SupplierName,
p.FullName as ContractPerson
from Purchasing.Suppliers s
left join Purchasing.PurchaseOrders po on po.SupplierID = s.SupplierID and po.ExpectedDeliveryDate between '2013-01-01' and '2013-01-31'
join Application.DeliveryMethods dm on dm.DeliveryMethodID = po.DeliveryMethodID
join Application.People p on p.PersonID = po.ContactPersonID
where dm.DeliveryMethodName in ('Air Freight','Refrigerated Air Freight') and po.IsOrderFinalized =1

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/
select top 10
o.OrderId,
ol.Description,
p1.FullName as SalesPersonName,
c.CustomerName as ClientPersonName
from [Sales].[Orders] o
join [Sales].[OrderLines] ol on ol.OrderID = o.OrderID
join [Application].[People] p1 on p1.PersonID = o.SalespersonPersonID
join [Sales].[Customers] c on c.CustomerID = o.CustomerID
order by OrderDate desc

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

select distinct c.CustomerName,c.PhoneNumber
from [Sales].[Orders] o
join [Sales].[OrderLines] ol on o.OrderID = o.OrderID
join [Sales].[Customers] c on c.CustomerID = o.CustomerID
join [Warehouse].[StockItems] s on s.StockItemID = ol.StockItemID  and s.StockItemName = 'Chocolate frogs 250g'