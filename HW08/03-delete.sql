
DELETE FROM	Warehouse.Colors WHERE ColorName like '%[1-9]%'; --подготовка
DROP TABLE IF EXISTS Warehouse.Colors_DeleteDemo;

SELECT ColorId, ColorName, LastEditedBy 
INTO Warehouse.Colors_DeleteDemo
FROM Warehouse.Colors

INSERT INTO Warehouse.Colors_DeleteDemo
	(ColorId, ColorName, LastEditedBy)
VALUES
	(NEXT VALUE FOR Sequences.ColorID,'Dark Blue11991', 1), 
	(NEXT VALUE FOR Sequences.ColorID,'Light Blue119991', 1)

select * from Warehouse.Colors_DeleteDemo

-- удаление существующих в Warehouse.Colors
DELETE FROM Demo
FROM Warehouse.Colors_DeleteDemo AS Demo
JOIN Warehouse.Colors AS C ON Demo.ColorName = C.ColorName;

Drop table IF EXISTS Warehouse.Colors_DeleteDemo;

---удаление дублирующих строк
SELECT ColorId, ColorName, LastEditedBy 
INTO Warehouse.Colors_DeleteDemo
FROM Warehouse.Colors;


insert into Warehouse.Colors_DeleteDemo
select * from Warehouse.Colors_DeleteDemo
where colorid between 18 and 20;


select	row_number() over (partition by colorname order by colorname) as nomer, 
	colorid, colorname, lasteditedby
from Warehouse.Colors_DeleteDemo
order by nomer desc 


--- удаление дублей
with del AS (
	select	row_number() over (partition by colorname order by colorname) as nomer
	from Warehouse.Colors_DeleteDemo
) 
delete from del where nomer > 1

------ удаление строк по частям (батчевый метод)
drop table if exists Sales.Invoices_Q12016_Archive
drop table if exists Sales.Invoices_Q12016

select * 
into Sales.Invoices_Q12016
from Sales.Invoices
where InvoiceDate >= '2016-01-01' and InvoiceDate < '2017-01-01'

-- копирование структуры таблицы, без строк
select * 
into Sales.Invoices_Q12016_Archive
from Sales.Invoices_Q12016
where 1 = 0

select count(*) from Sales.Invoices_Q12016

DECLARE @rowcount INT, @batchsize INT = 1000; 
SET @rowcount = @batchsize;

--- удаление по частям
WHILE @rowcount = @batchsize
BEGIN
	-- удаление со втавкой в др таблицу
	DELETE top (@batchsize) FROM Sales.Invoices_Q12016
	OUTPUT deleted.*
	INTO Sales.Invoices_Q12016_Archive
	--OUTPUT deleted.InvoiceID
	WHERE InvoiceDate >= '2016-01-01' AND InvoiceDate < '2016-04-01';

	SET @rowcount = @@ROWCOUNT;
END
select count(*) from Sales.Invoices_Q12016_Archive