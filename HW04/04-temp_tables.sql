-- область видимости - текущий сеанс

drop table if exists #test
CREATE TABLE #test (PersonID INT, PetName VARCHAR(50));

INSERT INTO #test (PersonID, PetName)
VALUES (1, 'Alice'), (2, 'Jacky'), (3, 'Layka');

SELECT * FROM #test -- в текущем сеансе
SELECT * FROM #test -- в новом сеансе

--------------------
--глобальные временные таблицы - видны всем

-- в другом сеансе Ctrl + N
drop table if exists ##test
CREATE TABLE ##test (PersonID INT, PetName VARCHAR(50));

-- этот сеанс
INSERT INTO ##test (PersonID, PetName)
VALUES (1, 'Alice'), (2, 'Jacky'), (3, 'Layka');

-- другой сеанс + закрыть окно
SELECT * FROM ##test; 

DROP TABLE ##test;

-----
-- область видимости - текущий пакет операций
DECLARE @test_var TABLE (PersonID INT, PetName VARCHAR(50))

INSERT INTO @test_var (PersonID, PetName)
VALUES (1, 'Alice'), (2, 'Jacky'), (3, 'Layka')

SELECT * FROM @test_Var

SELECT *
FROM #test AS test
JOIN Application.People AS P ON P.PersonID = test.PersonID

SELECT *
FROM @test_var AS test
JOIN Application.People AS P ON P.PersonID = test.PersonID

---------------------------------------
-- в каких из этих 3 таблиц могут быть индексы ?
create table #t1 (a int, b int)
create table ##t2 (a int, b int) 
declare @t3 table (a int, b int) 

--pgdn




create index ix_t1 on #t1(a)
create index ix_t2 on ##t2(a)

declare @t3 table (a int primary key, b int);
insert @t3 (a, b) values(5, 1), (4, 1), (11, 0)
-- Ctrl + M
select * from @t3 where a = 5