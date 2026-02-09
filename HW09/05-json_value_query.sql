-- ISJSON
/*
extraction (JSON_VALUE / JSON_QUERY)
array enumeration (OPENJSON)
enforcing JSON with a CHECK constraint
modifying JSON (JSON_MODIFY) 
pivoting JSON properties
*/

-- валидность
DECLARE @jsonDataWithError AS NVARCHAR(MAX) = N'{"OrderId": 5, "CustomerId: 6}';
SELECT ISJSON(@jsonDataWithError);
-- 0, т.к. в JSON есть ошибка; исправить, проверить

-- ---------------------------------
-- хранение в таблице
DROP TABLE IF EXISTS #BooksJson;

-- Использование ISJSON в ограничении CHECK
CREATE TABLE #BooksJson(
    BookId INT PRIMARY KEY,
    BookDoc NVARCHAR(MAX) NOT NULL CHECK (ISJSON(BookDoc) = 1)
);

INSERT INTO #BooksJson VALUES (1, '
    {
        "category": "ITPro",
        "title": "Programming SQL Server",
        "author": "Lenni Lobel",
        "price": {
            "amount": 49.99,
            "currency": "USD"
        },
        "purchaseSites": [
            "amazon.com",
            "booksonline.com"
        ]
    }
');

INSERT INTO #BooksJson VALUES (2, '
    {
        "category": "Developer",
        "title": "Developing ADO .NET",
        "author": "Andrew Brust",
        "price": {
            "amount": 39.93,
            "currency": "USD"
        },
        "purchaseSites": [
            "booksonline.com"
        ]
    }
');

INSERT INTO #BooksJson VALUES (3, '
    {
        "category": "ITPro",
        "title": "Windows Cluster Server",
        "author": "Stephen Forte",
        "price": {
            "amount": 59.99,
            "currency": "CAD"
        },
        "purchaseSites": [
            "amazon.com"
        ]
    }
');

SELECT BookId, BookDoc FROM #BooksJson;

-- функции для работы
-- extract a scalar JSON property using JSON_VALUE (category)
SELECT BookId, JSON_VALUE(BookDoc, '$.category') AS BookCategory, BookDoc
FROM #BooksJson;

-- non-existent path (returns NULL, no error)
SELECT BookId, JSON_VALUE(BookDoc, '$.not_exist_property') AS BookCategory, BookDoc
FROM #BooksJson;

-- strict -> error
SELECT BookId, JSON_VALUE(BookDoc, 'strict$.not_exist_property') AS BookCategory, BookDoc
FROM #BooksJson;

-- extract nested scalar and JSON fragment (array) using JSON_VALUE and JSON_QUERY
SELECT BookId,
    --scalar
    JSON_VALUE(BookDoc, '$.category') AS Category,
    JSON_VALUE(BookDoc, '$.title') AS Title,
    JSON_VALUE(BookDoc, '$.price.amount') AS PriceAmount,
    JSON_VALUE(BookDoc, '$.price.currency') AS PriceCurrency,
    --json
    JSON_QUERY(BookDoc, '$.purchaseSites') AS PurchaseSites,
    JSON_VALUE(BookDoc, '$.purchaseSites[0]') AS FirstPurchaseSite -- 1й элемент массива
 FROM #BooksJson;

----
-- Хотим найти книги на 'amazon.com' ($.purchaseSites) 
-- Выводим книгу и на каких сайтах продается
-- enumerate array purchaseSites
SELECT BookId, JSON_VALUE(BookDoc, '$.title') AS Title, JSON_QUERY(BookDoc, '$.purchaseSites') AS PurchaseSites
    , sites.[key], sites.value
FROM #BooksJson
CROSS APPLY OPENJSON(BookDoc, '$.purchaseSites') sites -- развернем массив purchaseSites

-- filter
SELECT BookId, JSON_VALUE(BookDoc, '$.title') AS Title, JSON_QUERY(BookDoc, '$.purchaseSites') AS PurchaseSites
    , sites.[key], sites.value
FROM #BooksJson
CROSS APPLY OPENJSON(BookDoc, '$.purchaseSites') sites -- развернем массив purchaseSites
WHERE sites.value = 'amazon.com';

DROP TABLE #BooksJson;

-- -----------------
-- JSON MODIFY

USE WideWorldImporters;
-- show JSON_MODIFY result
SELECT CustomFields, JSON_VALUE(CustomFields, '$.Tags[1]') as origin
    , JSON_MODIFY(CustomFields, '$.Tags[1]', 'Super Sound') /* вернет измененнное значение, без изменения в таблице */
FROM Warehouse.StockItems
WHERE StockItemID = 63

----------
-- update
UPDATE Warehouse.StockItems SET CustomFields = JSON_MODIFY(CustomFields, '$.Tags[1]', 'Super Sound')
WHERE StockItemID = 63;

-- Verify the update by extracting the modified tag
SELECT CustomFields, JSON_VALUE(CustomFields, '$.Tags[1]')
FROM Warehouse.StockItems
WHERE StockItemID = 63;

-- --------------------------------
-- PIVOT, OPENJSON()
-- --------------------------------

SELECT TOP 5 * FROM Application.People

-- Свойства из JSON в столбцы
-- Extract JSON properties from CustomFields + pivot
;WITH peoples AS (
    SELECT
        PersonID,
        FullName,
        js.[Key] AS JsonKey,   -- ключ (будущие колонки)
        js.Value AS JsonValue, -- значение
        CustomFields
    FROM Application.People
    OUTER APPLY OPENJSON(CustomFields) js -- развернули json
)
SELECT *
FROM peoples
PIVOT (
    MAX(JsonValue)
    FOR JsonKey IN (OtherLanguages, HireDate, Title, PrimarySalesTerritory, CommissionRate)
) pvt
