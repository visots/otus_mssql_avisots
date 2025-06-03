-- view с подзапросом
DROP VIEW IF EXISTS Website.SalesManager
Go 

CREATE or alter VIEW Website.SalesManager 
AS
SELECT s.PersonID,
       s.FullName,      
       s.PhoneNumber,
       s.FaxNumber                
	   , (SELECT COUNT(*) FROM Sales.Orders WHERE SalespersonPersonID = s.PersonID) AS AmountOfSales
FROM Application.People AS s
WHERE s.IsSalesperson = 1
GO
select * FROM Website.SalesManager


-- view с привязкой к схеме
DROP VIEW IF EXISTS Website.SalesManagerIX
Go 

CREATE or alter VIEW Website.SalesManagerIX 
WITH SCHEMABINDING
AS
SELECT s.PersonID,
       s.FullName,      
       s.PhoneNumber,
       s.FaxNumber
	   , (SELECT COUNT(*) FROM Sales.Orders WHERE SalespersonPersonID = s.PersonID) AS AmountOfSales
FROM Application.People AS s
WHERE s.IsSalesperson = 1	
GO

-- error
alter table Application.People alter column PhoneNumber nvarchar(40)

-- материализованное view (индекс будет хранится на диске)
-- подзапросы невозможны => error
CREATE UNIQUE CLUSTERED INDEX IXV_WebsiteSalesManager ON Website.SalesManagerIX (PersonID)
GO

-- план будет отличаться, тк есть подзапрос
-- SELECT * FROM Website.SalesManager WHERE PersonID = 7

-- планы - индекс не используется (Ctrl + M)
SELECT * FROM Website.SalesManagerIX WHERE PersonID = 7

SELECT * FROM Website.SalesManagerIX with (noexpand) WHERE PersonID = 7
GO
