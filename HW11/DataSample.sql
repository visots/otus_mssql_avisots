
SET NOCOUNT ON;


INSERT INTO MeasurementUnits (Guid, Name, Code)
VALUES
(NEWID(), N'Celsius', 'C'),
(NEWID(), N'Percent', '%'),
(NEWID(), N'Pascal', 'PA'),
(NEWID(), N'Volt', 'V'),
(NEWID(), N'Ampere', 'A');


INSERT INTO Sensors (Guid, SensorName, SensorCode)
VALUES
(NEWID(), N'Boiler Room Sensor', 'SENSOR_001'),
(NEWID(), N'Outdoor Weather Sensor', 'SENSOR_002'),
(NEWID(), N'UPS Monitoring Sensor', 'SENSOR_003');


INSERT INTO Parameters (Guid, Name, Code, UnitId)
VALUES
(
    NEWID(),
    N'Temperature',
    'TEMP',
    (SELECT UnitId FROM MeasurementUnits WHERE Code = 'C')
),
(
    NEWID(),
    N'Humidity',
    'HUM',
    (SELECT UnitId FROM MeasurementUnits WHERE Code = '%')
),
(
    NEWID(),
    N'Pressure',
    'PRESS',
    (SELECT UnitId FROM MeasurementUnits WHERE Code = 'PA')
),
(
    NEWID(),
    N'Voltage',
    'VOLT',
    (SELECT UnitId FROM MeasurementUnits WHERE Code = 'V')
),
(
    NEWID(),
    N'Current',
    'CURR',
    (SELECT UnitId FROM MeasurementUnits WHERE Code = 'A')
);

INSERT INTO SensorAttributes
(
    SensorId,
    Guid,
    AttributeName,
    AttributeCode,
    UnitId
)
VALUES
(
    (SELECT SensorId FROM Sensors WHERE SensorCode = 'SENSOR_001'),
    NEWID(),
    N'Location',
    'LOCATION',
    (SELECT UnitId FROM MeasurementUnits WHERE Code = '%')
),
(
    (SELECT SensorId FROM Sensors WHERE SensorCode = 'SENSOR_001'),
    NEWID(),
    N'Firmware Version',
    'FW_VERSION',
    (SELECT UnitId FROM MeasurementUnits WHERE Code = '%')
),
(
    (SELECT SensorId FROM Sensors WHERE SensorCode = 'SENSOR_002'),
    NEWID(),
    N'Installation Zone',
    'ZONE',
    (SELECT UnitId FROM MeasurementUnits WHERE Code = '%')
);


INSERT INTO SensorAttributesValues (AttributeId, Value)
VALUES
(
    (
        SELECT AttributeId
        FROM SensorAttributes
        WHERE AttributeCode = 'LOCATION'
    ),
    N'Boiler room floor 1'
),
(
    (
        SELECT AttributeId
        FROM SensorAttributes
        WHERE AttributeCode = 'FW_VERSION'
    ),
    N'1.0.5'
),
(
    (
        SELECT AttributeId
        FROM SensorAttributes
        WHERE AttributeCode = 'ZONE'
    ),
    N'North sector'
);


INSERT INTO SensorParameters
(
    SensorId,
    ParameterId,
    IsActive
)
VALUES
(
    (SELECT SensorId FROM Sensors WHERE SensorCode = 'SENSOR_001'),
    (SELECT ParameterId FROM Parameters WHERE Code = 'TEMP'),
    1
),
(
    (SELECT SensorId FROM Sensors WHERE SensorCode = 'SENSOR_001'),
    (SELECT ParameterId FROM Parameters WHERE Code = 'HUM'),
    1
),
(
    (SELECT SensorId FROM Sensors WHERE SensorCode = 'SENSOR_002'),
    (SELECT ParameterId FROM Parameters WHERE Code = 'TEMP'),
    1
),
(
    (SELECT SensorId FROM Sensors WHERE SensorCode = 'SENSOR_002'),
    (SELECT ParameterId FROM Parameters WHERE Code = 'PRESS'),
    1
),
(
    (SELECT SensorId FROM Sensors WHERE SensorCode = 'SENSOR_003'),
    (SELECT ParameterId FROM Parameters WHERE Code = 'VOLT'),
    1
),
(
    (SELECT SensorId FROM Sensors WHERE SensorCode = 'SENSOR_003'),
    (SELECT ParameterId FROM Parameters WHERE Code = 'CURR'),
    1
);


INSERT INTO SensorParametersValues
(
    SensorParameterId,
    MeasureDate,
    Value
)
VALUES
(
    (
        SELECT TOP 1 SP.SensorParameterId
        FROM SensorParameters SP
        INNER JOIN Parameters P
            ON P.ParameterId = SP.ParameterId
        INNER JOIN Sensors S
            ON S.SensorId = SP.SensorId
        WHERE
            S.SensorCode = 'SENSOR_001'
            AND P.Code = 'TEMP'
    ),
    '2026-05-15',
    23.45
),
(
    (
        SELECT TOP 1 SP.SensorParameterId
        FROM SensorParameters SP
        INNER JOIN Parameters P
            ON P.ParameterId = SP.ParameterId
        INNER JOIN Sensors S
            ON S.SensorId = SP.SensorId
        WHERE
            S.SensorCode = 'SENSOR_001'
            AND P.Code = 'HUM'
    ),
    '2026-05-15',
    41.20
),
(
    (
        SELECT TOP 1 SP.SensorParameterId
        FROM SensorParameters SP
        INNER JOIN Parameters P
            ON P.ParameterId = SP.ParameterId
        INNER JOIN Sensors S
            ON S.SensorId = SP.SensorId
        WHERE
            S.SensorCode = 'SENSOR_002'
            AND P.Code = 'TEMP'
    ),
    '2026-05-15',
    12.70
),
(
    (
        SELECT TOP 1 SP.SensorParameterId
        FROM SensorParameters SP
        INNER JOIN Parameters P
            ON P.ParameterId = SP.ParameterId
        INNER JOIN Sensors S
            ON S.SensorId = SP.SensorId
        WHERE
            S.SensorCode = 'SENSOR_002'
            AND P.Code = 'PRESS'
    ),
    '2026-05-15',
    101325.00
),
(
    (
        SELECT TOP 1 SP.SensorParameterId
        FROM SensorParameters SP
        INNER JOIN Parameters P
            ON P.ParameterId = SP.ParameterId
        INNER JOIN Sensors S
            ON S.SensorId = SP.SensorId
        WHERE
            S.SensorCode = 'SENSOR_003'
            AND P.Code = 'VOLT'
    ),
    '2026-05-15',
    220.40
),
(
    (
        SELECT TOP 1 SP.SensorParameterId
        FROM SensorParameters SP
        INNER JOIN Parameters P
            ON P.ParameterId = SP.ParameterId
        INNER JOIN Sensors S
            ON S.SensorId = SP.SensorId
        WHERE
            S.SensorCode = 'SENSOR_003'
            AND P.Code = 'CURR'
    ),
    '2026-05-15',
    4.80
);
