-- xml 2 table
--------------
-- 1. OPEN XML

-- Этот пример запустить сразу весь по [F5]
-- предварительно проверив ниже путь к файлу 02-open_xml.xml
-- открыть в браузере! file:///D:/repos/sql-otus-repo/1-11_xml_json/02-open_xml.xml
-- ... и разделить экран

-- Шаблон использования
DECLARE @xmlDocument XML; --!! тип

SELECT @xmlDocument = BulkColumn
FROM OPENROWSET(BULK 'D:\repos\sql-otus-repo\1-11_xml_json\02-open_xml.xml', SINGLE_CLOB) as t

DECLARE @docHandle INT;
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument;

SELECT *
FROM OPENXML(@docHandle, N'/Orders/Order') --путь к строкам
WITH ( 
	[ID] INT  '@ID', -- атрибут <Order ID="1">
	[OrderNum] INT 'OrderNumber', -- элемент <OrderNumber>1</OrderNumber>
	[CustomerNum] INT 'CustomerNumber',
	[City] NVARCHAR(10) 'Address/City',
	[Address] xml 'Address',
	[OrderDate] DATE 'OrderDate')

-- удаляем handle
EXEC sp_xml_removedocument @docHandle;

-- смотрим - что в переменных, docHandle - это просто число
SELECT @docHandle AS docHandle, @xmlDocument AS [@xmlDocument];

--------------
-- 2. XQuery => nodes() + value() см. 04-xml_data_type.sql