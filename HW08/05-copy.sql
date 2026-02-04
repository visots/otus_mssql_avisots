
/*
Msg 15281, Level 16, State 1, Procedure master..xp_cmdshell, Line 1 [Batch Start Line 0]
SQL Server blocked access to procedure 'sys.xp_cmdshell' of component 'xp_cmdshell' because this component is turned off as part of the security configuration for this server. 
A system administrator can enable the use of 'xp_cmdshell' by using sp_configure. For more information about enabling 'xp_cmdshell', search for 'xp_cmdshell' in SQL Server Books Online.
*/

-- To allow advanced options to be changed.  
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  

SELECT @@SERVERNAME
-- вставить свое имя сервера и путь к файлу выгрузки
-- -T = Trusted connection  (Windows Authentication / integrated security)
-- -w = wide = unicode 
-- -t <разделитель> 
-- -S <имя сервера>
exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.InvoiceLines" out  "D:\Temp\InvoiceLines1.txt" -T -w -t, -S home\SQL2022'
exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.InvoiceLines" out  "D:\Temp\InvoiceLines2.txt" -T -w -t"@eu&$1&" -S home\SQL2022'
-----------
drop table if exists Sales.InvoiceLines_BulkDemo
-- копируем структуру таблицы
select * into Sales.InvoiceLines_BulkDemo from Sales.InvoiceLines where 1=0

BULK INSERT Sales.InvoiceLines_BulkDemo
FROM "D:\Temp\InvoiceLines2.txt"
WITH (
		BATCHSIZE = 1000,       -- commit every 1000 rows
		DATAFILETYPE = 'widechar', -- file uses Unicode widechar format (BCP -w)
		FIELDTERMINATOR = '@eu&$1&', -- custom delimiter used in the BCP command above
		ROWTERMINATOR ='\n',   -- newline row terminator (may need '\r\n' for Windows files)
		KEEPNULLS,
		TABLOCK         
		);

select Count(*) from Sales.InvoiceLines_BulkDemo

TRUNCATE TABLE Sales.InvoiceLines_BulkDemo
