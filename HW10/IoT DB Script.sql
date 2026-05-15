
CREATE TABLE [Sensors] (
    [SensorId] int IDENTITY(1,1) NOT NULL ,
    [Guid] uniqueidentifier  NOT NULL ,
    [SensorName] nvarchar(250)  NOT NULL ,
    [SensorCode] nvarchar(20)  NOT NULL ,
    CONSTRAINT [PK_Sensors] PRIMARY KEY CLUSTERED (
        [SensorId] ASC
    )
)

CREATE TABLE [SensorAttributes] (
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

CREATE TABLE [SensorAttributesValues] (
    [Id] bigint IDENTITY(1,1) NOT NULL ,
    [AttributeId] int  NOT NULL ,
    [Value] nvarchar(200)  NOT NULL ,
    CONSTRAINT [PK_SensorAttributesValues] PRIMARY KEY CLUSTERED (
        [Id] ASC
    )
)

CREATE TABLE [Parameters] (
    [ParameterId] int IDENTITY(1,1) NOT NULL ,
    [Guid] uniqueidentifier  NOT NULL ,
    [Name] nvarchar(250)  NOT NULL ,
    [Code] nvarchar(20)  NOT NULL ,
    [UnitId] int  NOT NULL ,
    CONSTRAINT [PK_Parameters] PRIMARY KEY CLUSTERED (
        [ParameterId] ASC
    )
)

CREATE TABLE [SensorParameters] (
    [SensorParameterId] int IDENTITY(1,1) NOT NULL ,
    [SensorId] int  NOT NULL ,
    [ParameterId] int  NOT NULL ,
    [IsActive] bit  NOT NULL ,
    CONSTRAINT [PK_SensorParameters] PRIMARY KEY CLUSTERED (
        [SensorParameterId] ASC
    )
)

CREATE TABLE [SensorParametersValues] (
    [Id] bigint IDENTITY(1,1) NOT NULL ,
    [SensorParameterId] int  NOT NULL ,
    [MeasureDate] datetime  NOT NULL ,
    [Value] decimal(13,5)  NOT NULL ,
    CONSTRAINT [PK_SensorParametersValues] PRIMARY KEY CLUSTERED (
        [Id] ASC
    )
)

CREATE TABLE [MeasurementUnits] (
    [UnitId] int IDENTITY(1,1) NOT NULL ,
    [Guid] uniqueidentifier  NOT NULL ,
    [Name] nvarchar(250)  NOT NULL ,
    [Code] nvarchar(20)  NOT NULL ,
    CONSTRAINT [PK_MeasurementUnits] PRIMARY KEY CLUSTERED (
        [UnitId] ASC
    )
)

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