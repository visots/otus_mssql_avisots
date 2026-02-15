/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

-------OPENXML:
DECLARE @xml XML;

SELECT @xml = BulkColumn
FROM OPENROWSET(BULK 'C:\Users\avisots\source\repos\otus_mssql_avisots\HW09\StockItems.xml', SINGLE_CLOB) as t

declare @temp table 
(
	[StockItemName] nvarchar(300)  , 
	[SupplierId] int ,
	[UnitPackageId] int,
	[OuterPackageID] int,
	QuantityPerOuter int,
	TypicalWeightPerUnit float,
	LeadTimeDays int,
	IsChillerStock bit,
	TaxRate float,
	UnitPrice float 
)


DECLARE @docHandle INT;
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xml;

insert into @temp
SELECT *
FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( 
	[StockItemName] nvarchar(300)  '@Name', 
	[SupplierId] int 'SupplierID',
	[UnitPackageId] int 'Package/UnitPackageID',
	[OuterPackageID] int 'Package/OuterPackageID',
	QuantityPerOuter int 'Package/QuantityPerOuter',
	TypicalWeightPerUnit float 'Package/TypicalWeightPerUnit',
	LeadTimeDays int 'LeadTimeDays',
	IsChillerStock bit 'IsChillerStock',
	TaxRate float 'TaxRate',
	UnitPrice float 'UnitPrice' 
)

------XQuery:
--insert into @temp
--select 
-- i.value('(@Name)[1]','nvarchar (300)') as StockItemName,
-- i.value('(SupplierID)[1]','int') as SupplierId,
-- i.value('(Package/UnitPackageID)[1]','int') as UnitPackageId,
-- i.value('(Package/OuterPackageID)[1]','int') as OuterPackageID,
-- i.value('(Package/QuantityPerOuter)[1]','int') as QuantityPerOuter,
-- i.value('(Package/TypicalWeightPerUnit)[1]','float') as TypicalWeightPerUnit,
-- i.value('(LeadTimeDays)[1]','int') as LeadTimeDays,
-- i.value('(IsChillerStock)[1]','bit') as IsChillerStock,
-- i.value('(TaxRate)[1]','float') as TaxRate,
-- i.value('(UnitPrice)[1]','float') as UnitPrice
--from @xml.nodes('/StockItems/Item') as x(i)

select * from @temp

select * from Warehouse.StockItems

merge Warehouse.StockItems as target
using @temp as source on source.[StockItemName] = target.[StockItemName]
when not matched by target then 
								insert (StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, 
										TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice,LastEditedBy)
								values (source.StockItemName, source.SupplierID, source.UnitPackageID, source.OuterPackageID, 
										source.QuantityPerOuter, source.TypicalWeightPerUnit, source.LeadTimeDays, source.IsChillerStock, 
										source.TaxRate, source.UnitPrice, 1)
when matched then update set target.StockItemName = source.StockItemName,
							 target.SupplierID=source.SupplierID
							,target.UnitPackageId =source.UnitPackageId 
							,target.OuterPackageID=source.OuterPackageID
							,target.QuantityPerOuter =source.QuantityPerOuter
							,target.TypicalWeightPerUnit =source.TypicalWeightPerUnit
							,target.LeadTimeDays =source.LeadTimeDays
							,target.IsChillerStock=source.IsChillerStock
							,target.TaxRate =source.TaxRate
							,target.UnitPrice =source.UnitPrice
output $action, deleted.*, inserted.*
;




return;
/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

select top 5 * from Warehouse.StockItems

select
	StockItemName as [Item/@Name], 
	SupplierID as [Item/SupplierId],
	UnitPackageID as [Item/Package/UnitPackageID],
	OuterPackageID as [Item/Package/OuterPackageID],
	QuantityPerOuter as [Item/Package/QuantityPerOuter],
	TypicalWeightPerUnit as [Item/Package/TypicalWeightPerUnit],
	LeadTimeDays as [Item/LeadTimeDays],
	IsChillerStock as [Item/IsChillerStock],
	TaxRate as [Item/TaxRate],
	UnitPrice as [Item/UnitPrice]
from Warehouse.StockItems
FOR XML PATH(''),ROOT('StockItems')


/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

select top 5 * from Warehouse.StockItems

select 
	StockItemId,
	StockItemName,
	json_value(CustomFields,'$.CountryOfManufacture') as CountryOfManufacture,
	json_value(CustomFields,'$.Tags[0]') as CountryOfManufacture
from Warehouse.StockItems

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/


select 
	StockItemId,
	StockItemName,
	Tags
from Warehouse.StockItems s
cross apply openjson(CustomFields, '$.Tags') as Tags
where Tags.value = 'Vintage'

--Развернутый массив Tags
;with FilteredItems as (
    select *
    from Warehouse.StockItems s
    where exists (
        select 1
        from openjson(s.CustomFields, '$.Tags')
        where value = 'Vintage'
    )
)
select 
    f.StockItemId,
    f.StockItemName,
    string_agg(t.value, ', ') as Tags
from FilteredItems f
cross apply openjson(f.CustomFields, '$.Tags') t
group by 
    f.StockItemId,
    f.StockItemName
