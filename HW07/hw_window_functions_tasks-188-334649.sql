/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
-- ---------------------------------------------------------------------------

USE WideWorldImporters

set statistics time, io on
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

-- в сумме по месяцам
--select datefromparts(year(i.InvoiceDate), month(i.InvoiceDate),1), sum(ExtendedPrice)
--from [Sales].[Invoices] i
--join [Sales].[InvoiceLines] il on il.InvoiceID = i.InvoiceID
--group by datefromparts(year(i.InvoiceDate), month(i.InvoiceDate),1)
--order by 1 asc

SELECT
    i.InvoiceID,
    c.CustomerName,
    i.InvoiceDate,
    SUM(il.ExtendedPrice) AS InvoiceAmount,

    (
        SELECT SUM(il2.ExtendedPrice)
        FROM Sales.Invoices i2
        JOIN Sales.InvoiceLines il2 ON il2.InvoiceID = i2.InvoiceID
        WHERE
            i2.InvoiceDate >= '2015-01-01'
            AND DATEFROMPARTS(YEAR(i2.InvoiceDate), MONTH(i2.InvoiceDate), 1)
                <= DATEFROMPARTS(YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), 1)
    ) AS CumulativeMonthlyAmount

FROM Sales.Invoices i
JOIN Sales.InvoiceLines il ON il.InvoiceID = i.InvoiceID
JOIN Sales.Customers c ON c.CustomerID = i.CustomerID
WHERE i.InvoiceDate >= '2015-01-01'
GROUP BY
    i.InvoiceID,
    c.CustomerName,
    i.InvoiceDate
ORDER BY i.InvoiceDate;

-- SQL Server Execution Times:
-- CPU time = 40109 ms,  elapsed time = 41325 ms.


/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

SELECT
    i.InvoiceID,
    c.CustomerName,
    i.InvoiceDate,
    SUM(il.ExtendedPrice) AS InvoiceAmount,
    m.CumulativeMonthlyAmount
FROM Sales.Invoices i
JOIN Sales.InvoiceLines il ON il.InvoiceID = i.InvoiceID
JOIN Sales.Customers c ON c.CustomerID = i.CustomerID
JOIN (
    SELECT
        DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) AS MonthDate,
        SUM(SUM(il.ExtendedPrice)) OVER (
            ORDER BY DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1)
            ROWS UNBOUNDED PRECEDING
        ) AS CumulativeMonthlyAmount
    FROM Sales.Invoices i
    JOIN Sales.InvoiceLines il ON il.InvoiceID = i.InvoiceID
    WHERE i.InvoiceDate >= '2015-01-01'
    GROUP BY
        YEAR(InvoiceDate),
        MONTH(InvoiceDate)
) m
    ON m.MonthDate = DATEFROMPARTS(YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), 1)
WHERE i.InvoiceDate >= '2015-01-01'
GROUP BY
    i.InvoiceID,
    c.CustomerName,
    i.InvoiceDate,
    m.CumulativeMonthlyAmount
ORDER BY i.InvoiceDate;


 --SQL Server Execution Times:
 --CPU time = 687 ms,  elapsed time = 1577 ms.

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

напишите здесь свое решение
select * from [Sales].[OrderLines]
select * from [Sales].[Orders]

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

напишите здесь свое решение

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

напишите здесь свое решение

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

напишите здесь свое решение

Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 