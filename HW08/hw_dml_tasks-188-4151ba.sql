/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/
SELECT * FROM [Purchasing].[Suppliers]
WHERE SupplierName like 'Test%'

INSERT INTO Purchasing.Suppliers (
    SupplierName,
    SupplierCategoryID,
    PrimaryContactPersonID,
    AlternateContactPersonID,
    DeliveryMethodID,
    DeliveryCityID,
    PostalCityID,
    SupplierReference,
    BankAccountName,
    BankAccountBranch,
    BankAccountCode,
    BankAccountNumber,
    BankInternationalCode,
    PaymentDays,
    InternalComments,
    PhoneNumber,
    FaxNumber,
    WebsiteURL,
    DeliveryAddressLine1,
    DeliveryAddressLine2,
    DeliveryPostalCode,
    DeliveryLocation,
    PostalAddressLine1,
    PostalAddressLine2,
    PostalPostalCode,
    LastEditedBy
)
VALUES 
(N'Test Supplier 1',1,1,2,1,13870,13870,N'TEST1',N'Test Bank 1',N'Test1',N'12345',N'12345',N'123456',30,NULL,N'(111) 111-1111',N'(111) 111-111',N'https://test1.com',N' Test1',NULL,N'12345',NULL,N'Test1',NULL,N'12345',1),
(N'Test Supplier 2',1,1,2,1,13870,13870,N'TEST1',N'Test Bank 1',N'Test1',N'12345',N'12345',N'123456',30,NULL,N'(111) 111-1111',N'(111) 111-111',N'https://test1.com',N' Test1',NULL,N'12345',NULL,N'Test1',NULL,N'12345',1),
(N'Test Supplier 3',1,1,2,1,13870,13870,N'TEST1',N'Test Bank 1',N'Test1',N'12345',N'12345',N'123456',30,NULL,N'(111) 111-1111',N'(111) 111-111',N'https://test1.com',N' Test1',NULL,N'12345',NULL,N'Test1',NULL,N'12345',1),
(N'Test Supplier 4',1,1,2,1,13870,13870,N'TEST1',N'Test Bank 1',N'Test1',N'12345',N'12345',N'123456',30,NULL,N'(111) 111-1111',N'(111) 111-111',N'https://test1.com',N' Test1',NULL,N'12345',NULL,N'Test1',NULL,N'12345',1),
(N'Test Supplier 5',1,1,2,1,13870,13870,N'TEST1',N'Test Bank 1',N'Test1',N'12345',N'12345',N'123456',30,NULL,N'(111) 111-1111',N'(111) 111-111',N'https://test1.com',N' Test1',NULL,N'12345',NULL,N'Test1',NULL,N'12345',1)


/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE FROM Purchasing.Suppliers WHERE SupplierID = (SELECT TOP 1 SupplierId FROM  Purchasing.Suppliers WHERE SupplierName='Test Supplier 5')

/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE Purchasing.Suppliers
SET BankAccountName = 'Test Bank 4'
WHERE SupplierID = (SELECT TOP 1 SupplierId FROM  Purchasing.Suppliers WHERE SupplierName='Test Supplier 4')

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

--Временная таблица для сравнения
DROP TABLE IF exists #temp

SELECT * INTO #temp
FROM Purchasing.Suppliers
WHERE SupplierName like 'Test%'

--Обновляем одно поле в таблице сравнения
UPDATE #temp
SET SupplierReference = 'TEST2'

--Добавляем одну ранее удаленную запись в таблицу сравнения
INSERT INTO #temp
VALUES 
((NEXT VALUE FOR Sequences.SupplierId),N'Test Supplier 5',1,1,2,1,13870,13870,N'TEST1',N'Test Bank 1',N'Test1',N'12345',N'12345',N'123456',30,NULL,N'(111) 111-1111',N'(111) 111-111',N'https://test1.com',N' Test1',NULL,N'12345',NULL,N'Test1',NULL,N'12345',1,'2009-01-01','2020-01-01')

SELECT * FROM #temp

--Обновляем в таблице у тестовых записей поле SupplierReference
--Добаляем в таблицу ранее удаленную запись
merge Purchasing.Suppliers as target
using #temp as source on source.SupplierId = target.SupplierId
WHEN matched and target.SupplierReference != source.SupplierReference THEN UPDATE SET target.SupplierReference = source.SupplierReference
WHEN not matched by target THEN 
                            INSERT ( SupplierId,SupplierName,SupplierCategoryID,PrimaryContactPersonID,AlternateContactPersonID,DeliveryMethodID,DeliveryCityID,PostalCityID,SupplierReference,BankAccountName,BankAccountBranch,BankAccountCode,BankAccountNumber,BankInternationalCode,PaymentDays,InternalComments,PhoneNumber,FaxNumber,WebsiteURL,DeliveryAddressLine1,DeliveryAddressLine2,DeliveryPostalCode,DeliveryLocation,PostalAddressLine1,PostalAddressLine2,PostalPostalCode,LastEditedBy) 
                            VALUES (source.SupplierId,source.SupplierName,source.SupplierCategoryID,source.PrimaryContactPersonID,source.AlternateContactPersonID,source.DeliveryMethodID,source.DeliveryCityID,source.PostalCityID,source.SupplierReference,source.BankAccountName,source.BankAccountBranch,source.BankAccountCode,source.BankAccountNumber,source.BankInternationalCode,source.PaymentDays,source.InternalComments,source.PhoneNumber,source.FaxNumber,source.WebsiteURL,source.DeliveryAddressLine1,source.DeliveryAddressLine2,source.DeliveryPostalCode,source.DeliveryLocation,source.PostalAddressLine1,source.PostalAddressLine2,source.PostalPostalCode,source.LastEditedBy)
output $action, deleted.*,INSERTed.*;

SELECT * FROM Purchasing.Suppliers
WHERE SupplierName like 'Test%'

----удаляем из таблицы вновь созданную запись
--DELETE FROM Purchasing.Suppliers WHERE SupplierID = (SELECT TOP 1 SupplierId FROM  Purchasing.Suppliers WHERE SupplierName='Test Supplier 5')

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/
EXEC sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
RECONFIGURE;  
GO  

SELECT @@SERVERNAME --DESKTOP-0H0RL67
EXEC xp_cmdshell 'whoami'

exec master..xp_cmdshell 'bcp "[WideWorldImporters].[Purchasing].[Suppliers]" out  "C:\Temp\Suppliers.txt" -T -w -t"#1W34ES#" -S DESKTOP-0H0RL67'

DROP TABLE IF exists #temp_bulk
select * into #temp_bulk from [Purchasing].[Suppliers] 
where 1=0

BULK INSERT #temp_bulk
FROM "C:\Temp\Suppliers.txt"
WITH (
		BATCHSIZE = 1000,       -- commit every 1000 rows
		DATAFILETYPE = 'widechar', -- file uses Unicode widechar format (BCP -w)
		FIELDTERMINATOR = '#1W34ES#', -- custom delimiter used in the BCP command above
		ROWTERMINATOR ='\n',   -- newline row terminator (may need '\r\n' for Windows files)
		KEEPNULLS,
		TABLOCK         
		);

select * from #temp_bulk