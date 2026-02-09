-- xml 2 table
------------------------
-- OPENJSON

-- Этот пример запустить сразу весь по [F5]
-- предварительно проверив ниже путь к файлу 03-open_json.json -- посмотреть через интернет-браузер
-- открыть в браузере! file:///D:/repos/sql-otus-repo/1-11_xml_json/03-open_json.json
-- ... и разделить экран
-- Шаблон использования
DECLARE @json NVARCHAR(max); --!! тип

SELECT @json = BulkColumn
FROM OPENROWSET(BULK 'D:\repos\sql-otus-repo\1-11_xml_json\03-open_json.json', SINGLE_CLOB) AS data;

SELECT *
FROM OPENJSON (@json, '$.Suppliers') --путь к строкам
WITH (
    Id          INT,
    Supplier    NVARCHAR(100)   '$.SupplierInfo.Name', -- Name - свойство SupplierInfo
    Contact     NVARCHAR(MAX)   '$.Contact' AS JSON, --!! as JSON - будем парсить !!
    City        NVARCHAR(100)   '$.CityName'
) t
OUTER APPLY OPENJSON(t.Contact) WITH (
        PrimaryContact   NVARCHAR(100) '$.Primary',
        AlternateContact NVARCHAR(100) '$.Alternate'
    ) AS c


-- что в переменной
SELECT @json AS [@json]

------------------------
-- анализ структуры

-- OPENJSON Явное описание структуры
--$ - корень, . - разделитель уровней вложенности

-- OPENJSON Без структуры
SELECT * FROM OPENJSON(@json) -- массив

SELECT * FROM OPENJSON(@json, '$.Suppliers') -- элементы массива в строки, каждая строка - элемент 
-- Type:
--    0 = null
--    1 = string
--    2 = int
--    3 = bool
--    4 = array
--    5 = object

-- какие свойства есть у Suppliers[0]? 
SELECT * FROM OPENJSON(@json, '$.Suppliers[0]') -- 1й поставщик (1й элемент массива)







-- доступ к элементам массива
declare @s nvarchar(max) = N'{
    "@Id": 1,
    "Supplier": {
        "Name": "Test",
        "Tags": ["A", "B"]
    }
}'
select * 
from openjson(@s) with (
	Id int '$."@Id"'
	, Supplier nvarchar(10) '$.Supplier.Name'
	, Tag1 nvarchar(10) '$.Supplier.Tags[0]'
	, Tag2 nvarchar(10) '$.Supplier.Tags[1]'
	)

-- Warehouse.StockItems - CustomFields (json)
select CustomFields, t.* 
from Warehouse.StockItems as i
outer apply openjson(CustomFields) with (
	CountryOfManufacture nvarchar(20) '$.CountryOfManufacture'
	, Tag2 nvarchar(20) '$.Tags[1]'
	) t

select CustomFields, t.*
from Warehouse.StockItems as i
outer apply openjson(CustomFields, '$.Tags') t
where t.value = N'16GB'
