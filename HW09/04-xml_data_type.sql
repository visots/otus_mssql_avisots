-- xml - DATA TYPE
DROP TABLE IF EXISTS #table1;
CREATE TABLE #table1 (xmlcol XML);
GO

INSERT #table1 VALUES('<person/>');
INSERT #table1 VALUES('<person></person>');
INSERT #table1 VALUES('<person>

</person>');
GO

-- Представление будет одинаковое
SELECT xmlcol FROM #table1;
GO

-- Так будет ошибка
INSERT #table1 VALUES('<b><i>abc</b></i>');
INSERT #table1 VALUES('<person>abc</Person>');
GO

-- XML-документ
INSERT #table1 VALUES('<doc/>'); -- тэг без данных
INSERT #table1 VALUES('<doc/><doc/>'); -- Фрагмент документа
INSERT #table1 VALUES('Text only'); -- Только текст 
INSERT #table1 VALUES(''); -- Пустая строка
INSERT #table1 VALUES(NULL); -- NULL
SELECT xmlcol FROM #table1;

-------------------------------------
-- XML SCHEMA
USE WideWorldImporters;

-- Можно получить в FOR XML, указав XMLSCHEMA
-- встроенная схема
-- посмотреть в браузере file:///D:/repos/sql-otus-repo/1-11_xml_json/04-xml_schema.xsd

SELECT TOP 3 CityID,  CityName
FROM Application.Cities
FOR XML RAW('City'), ROOT('Cities'), XMLSCHEMA -- описание схемы: элементы, атрибуты, типы, длина, обязательность...  
/*
<xsd:schema targetNamespace="urn:schemas-microsoft-com:sql:SqlRowSet2" 
            xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
            xmlns:sqltypes="http://schemas.microsoft.com/sqlserver/2004/sqltypes" 
            elementFormDefault="qualified">
  <!-- Импорт типов SQL Server -->
  <xsd:import namespace="http://schemas.microsoft.com/sqlserver/2004/sqltypes" 
              schemaLocation="http://schemas.microsoft.com/sqlserver/2004/sqltypes/sqltypes.xsd" />
  
  <!-- Определение элемента City, required - обязательно к заполнению -->
  <xsd:element name="City">
    <xsd:complexType>
      <xsd:attribute name="CityID" type="sqltypes:int" use="required" />
      <xsd:attribute name="CityName" use="required">
        <xsd:simpleType>
          <xsd:restriction base="sqltypes:nvarchar" 
                          sqltypes:localeId="1033" 
                          sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" 
                          sqltypes:sqlCollationVersion="2">
            <xsd:maxLength value="50" />
          </xsd:restriction>
        </xsd:simpleType>
      </xsd:attribute>
    </xsd:complexType>
  </xsd:element>
</xsd:schema>
*/

-------------------------------------
-- Создание схемы в SQL Server
-- DROP XML SCHEMA COLLECTION TestXmlSchema
/*
структура для элемента <City>
2 атрибута: CityID (тип int) и CityName (строка до 50 символов)
атрибуты обязательные (use="required")
Programmability - Types - XML Schema Collections
*/
CREATE XML SCHEMA COLLECTION TestXmlSchema AS N'
 <xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema"
       xmlns:sqltypes="http://schemas.microsoft.com/sqlserver/2004/sqltypes" 
       elementFormDefault="qualified">
    <xsd:import namespace="http://schemas.microsoft.com/sqlserver/2004/sqltypes" schemaLocation="http://schemas.microsoft.com/sqlserver/2004/sqltypes/sqltypes.xsd" />
    <xsd:element name="City">
      <xsd:complexType>
        <xsd:attribute name="CityID" type="sqltypes:int" use="required" />
        <xsd:attribute name="CityName" use="required">
          <xsd:simpleType>
            <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlCollationVersion="2">
              <xsd:maxLength value="50" />
            </xsd:restriction>
          </xsd:simpleType>
        </xsd:attribute>
      </xsd:complexType>
    </xsd:element>
  </xsd:schema>'

-----------------------------
-- Использование XML Schema

-- удобная валидация

-- ок
DECLARE @XmlWithSchema1 XML(TestXmlSchema); -- привязка к схеме
SET @XmlWithSchema1 = '<City CityID="1" CityName="Aaronsburg" />'; -- xml валиден?
GO

-- error
DECLARE @XmlWithSchema2 XML(TestXmlSchema);  -- привязка к схеме
SET @XmlWithSchema2 = '<City CityID="abc" CityName="Aaronsburg" />'; -- xml валиден?
GO

-- error
DECLARE @XmlWithSchema2 XML(TestXmlSchema);  -- привязка к схеме
SET @XmlWithSchema2 = '<City CityID="2" CityNameASD="Aaronsburg" />'; -- xml валиден?
GO

-- ок
DECLARE @XmlWithoutSchema1 XML; -- нет привязки к схеме
SET @XmlWithoutSchema1 = '<CityAAA CityID="abc" Name="Aaronsburg" />'; -- xml валиден?
GO

-- ----------------------
-- XQuery - запросы к xml
-- ----------------------
-- !! Для запуска примера изменить путь к файлу 04-xml_data_type.xml,

DECLARE @x XML
SET @x = (
		SELECT *
		FROM OPENROWSET(BULK 'D:\repos\sql-otus-repo\1-11_xml_json\04-xml_data_type.xml', SINGLE_CLOB) AS d
		)
select @x

-- value(XQuery/XPath, Type) - возвращает скалярное (единичное) значение
-- query(XQuery/XPath) - возвращает XML
-- exists(XQuery/XPath) - проверяет есть ли данные; 0 - not exists, 1 - exists

SELECT 
   Id = @x.value('(/Suppliers/Supplier/@Id)[1]', 'int')
   , SupplierName = ltrim(@x.value('(/Suppliers/Supplier/Name)[1]', 'varchar(100)'))
   , Category = ltrim(@x.value('(/Suppliers/Supplier/SupplierInfo/Category)[1]', 'varchar(100)'))
   , Query_Contact = @x.query('(/Suppliers/Supplier/Contact)[1]')
   , Query_Contoso = @x.query('/Suppliers/Supplier/Name[text() = "Contoso,Ltd."]')
   , Exist_Contoso = @x.exist('/Suppliers/Supplier/Name[text() = "Contoso,Ltd."]')
   , Query_Microsoft = @x.query('/Suppliers/Supplier/Name[text() = "Microsoft"]')
   , Exist_Microsoft = @x.exist('/Suppliers/Supplier/Name[text() = "Microsoft"]') 
   , SupplierCount = @x.query('count(//Supplier)')
GO 

-- nodes(XQuery/XPath) - элемент => в строку 
-- Можно использовать вместо OPENXML

DECLARE @x XML
SET @x = (
		SELECT *
		FROM OPENROWSET(BULK 'D:\repos\sql-otus-repo\1-11_xml_json\04-xml_data_type.xml', SINGLE_BLOB) AS d
		)
SELECT  
  Id = t.Supplier.value('(@Id)[1]', 'int')
  , SupplierName = t.Supplier.value('(Name)[1]', 'varchar(100)')
  , Category = t.Supplier.value('(SupplierInfo/Category)[1]', 'varchar(100)')
  , t.Supplier.query('.')
FROM @x.nodes('/Suppliers/Supplier') AS t(Supplier)
