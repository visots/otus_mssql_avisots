--CREATE DATABASE IoT;

--USE IoT;

--Таблица устройств
CREATE TABLE [dbo].[Sensors] (
    [SensorId] int IDENTITY(1,1) NOT NULL ,
    [Guid] uniqueidentifier  NOT NULL ,
    [SensorName] nvarchar(250)  NOT NULL ,
    [SensorCode] nvarchar(20)  NOT NULL ,
    CONSTRAINT [PK_Sensors] PRIMARY KEY CLUSTERED (
        [SensorId] ASC
    )
)
--Таблица аттрибутов устройств
CREATE TABLE [dbo].[SensorAttributes] (
    [AttributeId] int IDENTITY(1,1) NOT NULL ,
    [SensorId] int  NOT NULL ,
    [Guid] uniqueidentifier  NOT NULL ,
    [AttributeName] nvarchar(250)  NOT NULL ,
    [AttributeCode] nvarchar(20)  NOT NULL ,
    [UnitId] int  NOT NULL ,
    CONSTRAINT [PK_SensorAttributes] PRIMARY KEY CLUSTERED (
        [AttributeId] ASC
    )
)
--Таблица значений аттрибутов
CREATE TABLE [dbo].[SensorAttributesValues] (
    [Id] bigint IDENTITY(1,1) NOT NULL ,
    [AttributeId] int  NOT NULL ,
    [Value] nvarchar(200)  NOT NULL ,
    CONSTRAINT [PK_SensorAttributesValues] PRIMARY KEY CLUSTERED (
        [Id] ASC
    )
)
--Таблица параметров
CREATE TABLE [dbo].[Parameters] (
    [ParameterId] int IDENTITY(1,1) NOT NULL ,
    [Guid] uniqueidentifier  NOT NULL ,
    [Name] nvarchar(250)  NOT NULL ,
    [Code] nvarchar(20)  NOT NULL ,
    [UnitId] int  NOT NULL ,
    CONSTRAINT [PK_Parameters] PRIMARY KEY CLUSTERED (
        [ParameterId] ASC
    )
)
--Таблица соответствия Устройство-Параметр
CREATE TABLE [dbo].[SensorParameters] (
    [SensorParameterId] int IDENTITY(1,1) NOT NULL ,
    [SensorId] int  NOT NULL ,
    [ParameterId] int  NOT NULL ,
    [IsActive] bit  NOT NULL ,
    CONSTRAINT [PK_SensorParameters] PRIMARY KEY CLUSTERED (
        [SensorParameterId] ASC
    )
)
--Таблица Значений
CREATE TABLE [dbo].[SensorParametersValues] (
    [Id] bigint IDENTITY(1,1) NOT NULL ,
    [SensorParameterId] int  NOT NULL ,
    [MeasureDate] datetime  NOT NULL ,
    [Value] decimal(13,5)  NOT NULL ,
    CONSTRAINT [PK_SensorParametersValues] PRIMARY KEY CLUSTERED (
        [Id] ASC
    )
)
--Таблица единиц измерений
CREATE TABLE [dbo].[MeasurementUnits] (
    [UnitId] int IDENTITY(1,1) NOT NULL ,
    [Guid] uniqueidentifier  NOT NULL ,
    [Name] nvarchar(250)  NOT NULL ,
    [Code] nvarchar(20)  NOT NULL ,
    CONSTRAINT [PK_MeasurementUnits] PRIMARY KEY CLUSTERED (
        [UnitId] ASC
    )
)
--Связи между таблицами и ключи
ALTER TABLE [SensorAttributes] WITH CHECK ADD CONSTRAINT [FK_SensorAttributes_SensorId] FOREIGN KEY([SensorId])
REFERENCES [Sensors] ([SensorId])

ALTER TABLE [SensorAttributes] CHECK CONSTRAINT [FK_SensorAttributes_SensorId]

ALTER TABLE [SensorAttributes] WITH CHECK ADD CONSTRAINT [FK_SensorAttributes_UnitId] FOREIGN KEY([UnitId])
REFERENCES [MeasurementUnits] ([UnitId])

ALTER TABLE [SensorAttributes] CHECK CONSTRAINT [FK_SensorAttributes_UnitId]

ALTER TABLE [SensorAttributesValues] WITH CHECK ADD CONSTRAINT [FK_SensorAttributesValues_AttributeId] FOREIGN KEY([AttributeId])
REFERENCES [SensorAttributes] ([AttributeId])

ALTER TABLE [SensorAttributesValues] CHECK CONSTRAINT [FK_SensorAttributesValues_AttributeId]

ALTER TABLE [Parameters] WITH CHECK ADD CONSTRAINT [FK_Parameters_UnitId] FOREIGN KEY([UnitId])
REFERENCES [MeasurementUnits] ([UnitId])

ALTER TABLE [Parameters] CHECK CONSTRAINT [FK_Parameters_UnitId]

ALTER TABLE [SensorParameters] WITH CHECK ADD CONSTRAINT [FK_SensorParameters_SensorId] FOREIGN KEY([SensorId])
REFERENCES [Sensors] ([SensorId])

ALTER TABLE [SensorParameters] CHECK CONSTRAINT [FK_SensorParameters_SensorId]

ALTER TABLE [SensorParameters] WITH CHECK ADD CONSTRAINT [FK_SensorParameters_ParameterId] FOREIGN KEY([ParameterId])
REFERENCES [Parameters] ([ParameterId])

ALTER TABLE [SensorParameters] CHECK CONSTRAINT [FK_SensorParameters_ParameterId]

ALTER TABLE [SensorParametersValues] WITH CHECK ADD CONSTRAINT [FK_SensorParametersValues_SensorParameterId] FOREIGN KEY([SensorParameterId])
REFERENCES [SensorParameters] ([SensorParameterId])

ALTER TABLE [SensorParametersValues] CHECK CONSTRAINT [FK_SensorParametersValues_SensorParameterId]

--Уникальные GUID
ALTER TABLE SensorAttributes
ADD CONSTRAINT UQ_SensorAttributes_Guid UNIQUE(Guid)

ALTER TABLE Parameters
ADD CONSTRAINT UQ_Parameters_Guid UNIQUE(Guid)

ALTER TABLE MeasurementUnits
ADD CONSTRAINT UQ_MeasurementUnits_Guid UNIQUE(Guid)

--Уникальные коды
ALTER TABLE Sensors
ADD CONSTRAINT UQ_Sensors_SensorCode UNIQUE(SensorCode)

ALTER TABLE MeasurementUnits
ADD CONSTRAINT UQ_Units_Code UNIQUE(Code)

ALTER TABLE Parameters
ADD CONSTRAINT UQ_Parameters_Code UNIQUE(Code)

--Индексы (наиболее часто используемые поля при соединениях)
CREATE NONCLUSTERED INDEX IX_SensorAttributes_SensorId
ON SensorAttributes (SensorId)

CREATE NONCLUSTERED INDEX IX_SensorAttributes_UnitId
ON SensorAttributes (UnitId)

CREATE NONCLUSTERED INDEX IX_SensorAttributesValues_AttributeId
ON SensorAttributesValues (AttributeId)

CREATE NONCLUSTERED INDEX IX_Parameters_UnitId
ON Parameters (UnitId)
CREATE NONCLUSTERED INDEX IX_SensorParameters_SensorId
ON SensorParameters (SensorId)

CREATE NONCLUSTERED INDEX IX_SensorParameters_ParameterId
ON SensorParameters (ParameterId)

CREATE NONCLUSTERED INDEX IX_SPV_SensorParameterId
ON SensorParametersValues (SensorParameterId)

-- + индекс по полю даты для фильтрации
CREATE NONCLUSTERED INDEX IX_SPV_Date
ON SensorParametersValues (MeasureDate)