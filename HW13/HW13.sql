EXEC sp_configure 'clr enabled', 1;
RECONFIGURE;

EXEC sp_configure 'clr strict security', 0;
RECONFIGURE;


CREATE ASSEMBLY RegexMatch
FROM 'C:\SQLCLR\CLRFunctions.dll'
WITH PERMISSION_SET = SAFE;

CREATE FUNCTION dbo.RegexMatch
(
    @input NVARCHAR(MAX),
    @pattern NVARCHAR(1000)
)
RETURNS BIT
AS EXTERNAL NAME
RegexMatch.[RegexFunctions.RegexFunctions].RegexMatch;

--Валидация адреса почты

    --1 Корректный адрес:
    print dbo.RegexMatch('test@mail.ru','^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')

    --2 Не корректный адрес:
    print dbo.RegexMatch('test.ru','^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')