
--В случае множества записей и наличия статистики должен будет выполняться index seek, 
--что обеспечит быстрое соединение таблиц и быструю фильтрацию по полям индекса
--CREATE NONCLUSTERED INDEX IX_SensorAttributes_SensorId
--ON SensorAttributes (SensorId)

SELECT *
FROM SensorAttributes
WHERE SensorId = 1

--CREATE NONCLUSTERED INDEX IX_SensorAttributes_UnitId
--ON SensorAttributes (UnitId)

SELECT sa.*
FROM SensorAttributes sa
JOIN  [dbo].[MeasurementUnits] u ON sa.UnitId = u.UnitId
WHERE u.Code = '%'

--CREATE NONCLUSTERED INDEX IX_SensorAttributesValues_AttributeId
--ON SensorAttributesValues (AttributeId)

SELECT *
FROM SensorAttributesValues
WHERE AttributeId = 1

--CREATE NONCLUSTERED INDEX IX_Parameters_UnitId
--ON Parameters (UnitId)

SELECT p.Name
FROM Parameters p
JOIN [dbo].[MeasurementUnits] u ON p.UnitId = u.UnitId
WHERE u.Code = 'V'

--CREATE NONCLUSTERED INDEX IX_SensorParameters_SensorId
--ON SensorParameters (SensorId)

SELECT sp.*
FROM SensorParameters sp
WHERE sp.SensorId = 2

--CREATE NONCLUSTERED INDEX IX_SensorParameters_ParameterId
--ON SensorParameters (ParameterId)

SELECT s.SensorName
FROM SensorParameters sp
JOIN Sensors s ON s.SensorId = sp.SensorId
JOIN Parameters p ON p.ParameterId = sp.ParameterId
WHERE p.Name = 'Temperature'

--CREATE NONCLUSTERED INDEX IX_SPV_SensorParameterId
--ON SensorParametersValues (SensorParameterId)

SELECT *
FROM SensorParametersValues
WHERE SensorParameterId = 1

--Т.к. БД для IoT то операции фильтрации по дате будут частымими - без индекса по полю даты не обойтись
--CREATE NONCLUSTERED INDEX IX_SPV_Date
--ON SensorParametersValues (MeasureDate)

SELECT *
FROM SensorParametersValues
WHERE MeasureDate >= '2026-05-01'
  AND MeasureDate < '2026-05-02'
