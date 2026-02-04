USE WideWorldImporters; 

--в подзапросе можно выбрать только 0 или 1 запись
SELECT C.CustomerName, (SELECT TOP 1 OrderId
                FROM Sales.Orders O
                WHERE O.CustomerID = C.CustomerID
					AND OrderDate < '2014-01-01'
                ORDER BY O.OrderDate DESC, O.OrderID DESC)
FROM Sales.Customers C
ORDER BY C.CustomerName;

-- сравнить кол-во строк!
-- последние 2 заказа, cross apply похож на inner join
SELECT C.CustomerName, O.*
FROM Sales.Customers C
CROSS APPLY (SELECT TOP 2 *
                FROM Sales.Orders O
                WHERE O.CustomerID = C.CustomerID
					AND OrderDate < '2014-01-01'
                ORDER BY O.OrderDate DESC, O.OrderID DESC) AS O
ORDER BY C.CustomerName;


--последние 2 заказа, outer apply похож на  left join
SELECT C.CustomerName, O.*
FROM Sales.Customers C
OUTER APPLY (SELECT TOP 2 *
                FROM Sales.Orders O
                WHERE O.CustomerID = C.CustomerID
					AND OrderDate < '2014-01-01'
                ORDER BY O.OrderDate DESC, O.OrderID DESC) AS O
ORDER BY C.CustomerName;


--function call
SELECT C.CustomerName, O.*
FROM Sales.Customers C
OUTER APPLY [Sales].[orders_customer](C.CustomerID) AS O
ORDER BY C.CustomerName;


-- читабельность
SELECT DATEADD(hh,DATEDIFF(hh,0,GETDATE()),0), 
		GETDATE(), 
		DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)

-- через group by и apply
SELECT CAST(DATEADD(mm,DATEDIFF(mm,0,P.OrderDate),0) AS DATE) AS PurchaseOrderMonth,
	COUNT(*) AS PurchaseCount
FROM Purchasing.PurchaseOrders AS P
GROUP BY CAST(DATEADD(mm,DATEDIFF(mm,0,P.OrderDate),0) AS DATE)
ORDER BY CAST(DATEADD(mm,DATEDIFF(mm,0,P.OrderDate),0) AS DATE);

--cross apply
SELECT CA.PurchaseOrderMonth,
	COUNT(*) AS PurchaseCount
FROM Purchasing.PurchaseOrders AS P
CROSS APPLY (
	SELECT 
		CAST(DATEADD(mm,DATEDIFF(mm,0,P.OrderDate),0) AS DATE) AS PurchaseOrderMonth
	) AS CA
GROUP BY CA.PurchaseOrderMonth
ORDER BY CA.PurchaseOrderMonth;
