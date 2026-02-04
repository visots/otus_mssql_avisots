/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

/*

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/

declare @columns nvarchar(max), 
		@query NVARCHAR(max);

select @columns = string_agg(convert(nvarchar(max), quotename(CustomerName)), ',') within group(order by CustomerName)
from [Sales].[Customers] c
where exists( select 1 from [sales].[invoices] i
			  where c.CustomerID=i.CustomerID)

select @columns --print однако обрезает строку...

set @query = 
'select 
format(InvoiceDate,''dd.MM.yyyy'') as InvoiceMonth,'+@columns+'
from (
		select 
			   i.InvoiceId,
		       datefromparts(year(i.InvoiceDate),month(i.InvoiceDate),1) as InvoiceDate,
			   c.CustomerName as CustomerName
		from [Sales].[Customers] as c
		JOIN [Sales].[Invoices] as i on i.CustomerID=c.CustomerID
	) as s
pivot (
	   count(s.InvoiceId) for s.CustomerName in ('+@columns+')) p
order by InvoiceMonth ASC'


PRINT @query;

EXEC(@query);