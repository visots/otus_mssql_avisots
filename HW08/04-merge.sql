drop table if exists t1
drop table if exists t2
go
create table t1 (id int, price numeric(15,2), comment varchar(20))
insert t1 (id, price) values (1, 100), (2, 200), (3, null), (5, 50)

create table t2 (id int, price numeric(15,2))
insert t2 (id, price) values (1, 10), (2, 20), (3, 100), (4, 200)

select * from t1
select * from t2
/* 2 таблицы - обработка t1 со сложной логикой:
t1.price is null - удаляем
в t2 есть тот же id -> t2.price * .9
в t2 нет такого же id -> t1.price = t1.price * 2
в t1 нет такого же id -> insert into t1 price = 0
*/

-- обработка t1 на основании t2
merge t1 as target
using t2 as source on source.id = target.id
-- 1. совпали + прайс не указан -> удаляем
when matched and target.price is null then delete
-- !! возможно только 1 условие
-- when matched and target.шв = 1 then delete -- error

-- 2. есть совпадение -> цена конкурентов * 0.9
when matched then update set price /*из targer*/ = source.price * 0.9
						, comment = concat(target.price, '->', source.price, '*0.9')
-- 3. в t2 нет такого id -> цена * 2
when not matched by source then update set price /*из targer*/ = target.price * 2
						, comment = concat(target.price, '->', target.price, '*2')
-- 4. в t1 нет такого id -> insert 
when not matched by target then insert (id, price, comment) values(source.id, 0, 'insert')
output $action, deleted.*, inserted.*
;

select * from t1 order by id

/*
MERGE simplifies upsert but has historical bugs and concurrency caveats. 
Ensure proper locking/retry logic in production 
or use separate INSERT/UPDATE/DELETE statements if needed.
*/