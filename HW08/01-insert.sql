USE WideWorldImporters;

INSERT INTO Warehouse.Colors (ColorId, ColorName, LastEditedBy)
VALUES (NEXT VALUE FOR Sequences.ColorID, 'Ohra1', 1)
	, (NEXT VALUE FOR Sequences.ColorID, 'Ohra2', 1)
	;

INSERT INTO Warehouse.Colors (ColorId, ColorName, LastEditedBy)
select NEXT VALUE FOR Sequences.ColorID, 'Ohra3', 1

drop table if exists Warehouse.Color_Copy
go
-- создаем таблицу Color_Copy с той же структурой, что и Colors
select ColorId, ColorName, LastEditedBy 
into Warehouse.Color_Copy
from Warehouse.Colors
where 1=0

-- вставка в 2 таблицы
INSERT INTO Warehouse.Colors (ColorId, ColorName, LastEditedBy)
	OUTPUT inserted.ColorId, inserted.ColorName, inserted.LastEditedBy
INTO Warehouse.Color_Copy (ColorId, ColorName, LastEditedBy)
	OUTPUT inserted.ColorId
VALUES
	(NEXT VALUE FOR Sequences.ColorID,'Ohra4', 1), 
	(NEXT VALUE FOR Sequences.ColorID,'Ohra5', 1);

SELECT @@ROWCOUNT -- сколько строк обработали

select top 3  * from Warehouse.Colors order by ColorId desc;
select top 3  * from Warehouse.Color_Copy order by ColorId desc;

-- не забываем про ограничения Alt+F1 на Warehouse.Colors
