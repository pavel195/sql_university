--Все задачи по бд

--Задача 1 

/*Для производителей, выпускающих ПК и ноутбуки вычислить суммарный объем памяти всех 
моделей. 
Вывод: производитель, суммарный объем памяти ПК, суммарный объем памяти ноутбуков
*/
select t1.maker,summa_laptop,summa_pc    ---Выводим производителя,сумму объёма памяти pc и laptop
from(select maker,sum(ram) summa_pc      
from products join pc on products.model = pc.model   ---Соединяем таблицы,чтобы вытащить и производителя и объём памяти
where products.type = 'pc'
group by maker) t1 join
(select maker,sum(ram) summa_laptop
from products join laptop on products.model = laptop.model    ---Соединяем таблицы,чтобы вытащить и производителя и объём памяти
where products.type = 'laptop'
group by maker) t2 on t1.maker = t2.maker      ---Соединяем таблицы,чтобы всё было в одной таблице

--Задача 2

/*Вывести список моделей ПК и ноутбуков для производителей, которые выпускают цветные принтеры.
Вывод: производитель, номер модели*/

select prds.maker, pcs.model from PC pcs
JOIN PRODUCTS prds on pcs.model = prds.model
where maker in (select prds.maker from PRINTER prnt JOIN PRODUCTS prds on prnt.model = prds.model where COLOR = 'y')
union
select prds.maker, lpt.model from LAPTOP lpt
JOIN PRODUCTS prds on lpt.model = prds.model
where maker in (select prds.maker from PRINTER prnt JOIN PRODUCTS prds on prnt.model = prds.model where COLOR = 'y')

--Задача 3

/*Для моделей ПК вывести следующие сведения:
производитель, номер модели, минимальная частота процессора, максимальный объем жесткого диска, средняя цена*/

select pr.Maker, pc.model, min(pc.speed) as min_speed, max(pc.ram) as max_ram, avg(pc.price) as avg_price
from pc join Products pr on pc.Model = pr.Model
group by pc.model, Maker

--Задача 4

/* Для производителеи? самых дорогих ноутбуков наи?ти самую дешевую модель ПК.
Вывод: производитель, номер модели самого дешевого ПК, цена. */

with bb as (select Maker, max(lt.Price) mp from Laptop lt
join Products prod on lt.model = prod.model
group by maker, lt.Model, prod.model),
	gg as (select Maker, min(pc.Price) minpr from pc
join Products prod on pc.model = prod.model
group by maker, pc.Model, prod.model) 


select distinct maker, pc.Model, min(price) from (select products.Maker, model from products
join bb on Products.Maker = bb.Maker
where type = 'pc') as mm
join pc on mm.Model = pc.Model
group by maker, pc.model

--Задача 5

/*Для производителя самого дешевого принтера найти самые дешевые ПК и ноутбук.
Вывод: номер модели, тип устройства, цена*/

select pc.model, price, type
from pc join products on pc.model = products.model
where maker = (select maker 
from printer join products on printer.model = products.model
where price = (select min(price) from printer)) 
and price = (select min(price) from pc)  
-- Ищем производителя, который выпускает самый дешевый принтер. Далее самый дешевый ПК у этого же производителя

union

select laptop.model, price, type
from laptop join products on laptop.model = products.model
where maker =  (select maker 
from printer join products on printer.model = products.model
where price = 
  (select min(price) from printer)) and price = 
  (select min(price) from laptop)
-- Ищем производителя, который выпускает самый дешевый принтер. Далее самый дешевый ноутбук у этого же производителя 

--Задача 6

/*Найти среднюю цену каждой модели среди всех типов устройств.
Вывод: производитель, номер модели, средняя цена модели*/
select Maker, t.model, avgp from 
(select model, avg(price) as avgp from laptop
group by model
union
select model, avg(price) as avgp from pc
group by model
union
select model, avg(price)as avgp from printer
group by model) as t 
join products on t.model = products.model
order by maker

--Задача 7

/*Для всех типов устройств вывести все модели с ценой не больше средней по данному типу 
устройства (т.е. ПК не дороже средней цены ПК, ноутбуки не дороже средней цены ноутбуков, 
принтеры не дороже средней цены принтеров). 
Вывод: производитель, номер модели, цена.
*/
select Maker, PC.Model, Price from Products join PC on PC.Model = Products.Model  
where price <= (select avg(price) avgPC from PC) --- Проверяю цена меньше средней стоимости
union   --- тут вроде понятно
select Maker, Laptop.Model, Price from Products join Laptop on Laptop.Model = Products.Model
where price <= (select avg(price) avgLap from Laptop)
union
select Maker, Printer.Model, Price from Products join Printer on Printer.Model = Products.Model
where price <= (select avg(price) avgPrint from Printer)

--Задача 8

--8. Вывести список самых дешевых моделей устройств каждого типа
--Вывод: производитель, тип устройства, номер модели, цена.

select min(price) mp, model, Type, maker from (
select row_number() over(order by price)rn,Laptop.model, price, type, Maker from Laptop join Products on Products.model = Laptop.Model
union
select row_number() over(order by price)rn,PC.model , price, type, Maker from PC join Products on Products.model = PC.Model
union
select row_number() over(order by price)rn,Printer.model, price, products.Type, Maker from Printer join Products on Products.model = Printer.Model
) t group by rn, model, type,maker having rn = 1

/*в селектах вывожу: модели, цены, типы. нумерую по ценам по возрастанию,
а в конце по этой нумерации вывожу минцену для каждого типа*/

--Задача 9

/* Для производителя ПК с самым большим номером модели из 
таблицы PC вывести список моделей ноутбуков этого производителя. 
Вывод: производитель, номер модели */

/* Вывод производителя и модель из products только если производитель =
производителю максимальной модели из pc и тип продукта это лаптоп */

select maker, model laptop_model from products 
where maker = (			-- Вложенный запрос для поиска производителя пк с наибольшим
select maker from (		-- номером модели. Можно его отдельно запустить, чтобы проверить.
select max(pc.model) model from pc) a
left join products pr on pr.model = a.model) 
and type = 'Laptop'
group by maker, model

/*Выводится пустота. Это потому что производитель Е 
(с самым большим номером модели PC) не производит лаптопы.
Но код абсолютно рабочий. Можно поменять max на min
и все проверить по табличкам: выводит B (минимальный 
номер модели) и модель лаптопа - 1750*/

--Задача 10

--Нет решения

--Задача 11

with prc as (select maker from Products
				where type in (select type from products where type = 'PC' or type = 'Printer')
				group by maker
				having count(distinct type) = 1), 

t1 as (select Maker, PC.model, price, p.type from PC
		left join Products p on PC.model = p.model
		where PC.model in (select model from Products where maker in (select maker from prc))
		union all
		select Maker, pr.model, price, p.type from Printer pr
		left join Products p on pr.model = p.model
		where pr.model in (select model from Products where maker in (select maker from prc))) 

select maker, Type, model,  avg(price) avg_price from t1 
group by maker, Type, model
order by maker 

--Задача 12

SELECT p.model, MIN(p.speed), MAX(p.speed), AVG(p.price) 
FROM PC AS p 
JOIN product AS p1 ON p.model = p1.model
WHERE speed > (SELECT AVG(speed) FROM laptop)
GROUP BY p.model

--Задача 13

SELECT bb.model, bb.type, bb.speed, bb.ram, bb.hd, bb.price 
FROM (SELECT p.Type, p.model, Speed, ram, hd, price,
	COUNT(*) over (partition by p.model) AS cnt
FROM Laptop 
JOIN Products p ON p.Model = Laptop.Model
UNION
SELECT p1.Type, p1.model, Speed, ram, hd,  price,
	COUNT(*) over (partition by p1.model) AS cnt
FROM pc 
JOIN Products AS p1 ON p1.Model = pc.Model) AS bb
WHERE bb.cnt > 1

--Задача 14

/*Для производителей, которые выпускают как минимум ПК и принтеры вывести перечень всех 
моделей. 
Вывод: производитель, номер модели, минимальная цена модели, максимальная цена модели, 
средняя цена модели.*/
with mkrs as (select maker from Products
				where type in (select type from products where type = 'PC' or type = 'Printer')
				group by maker
				having count(distinct type) = 2), -- Здесь создаётся простая таблица с производителями у которых есть и пк и принтеры
t1 as (select Maker, PC.model, price, p.type from PC
		left join Products p on PC.model = p.model
		where PC.model in (select model from Products where maker in (select maker from mkrs))
		union all
		select Maker, pr.model, price, p.type from Printer pr
		left join Products p on pr.model = p.model
		where pr.model in (select model from Products where maker in (select maker from mkrs))
		union all
		select Maker, l.model, price, p.type from Laptop l
		left join Products p on l.model = p.model
		where l.model in (select model from Products where maker in (select maker from mkrs))
		) -- Здесь объединяются таблицы PC, Printer, Laptop с моделями, которые есть только у производителей из таблицы mkrs (к каждой таблице присоединена таблица Makers для вывода производителя)

--select * from t1 (чтобы посмотреть что получилось)
select maker, model, min(price) model_min, max(price) model_max, avg(price) model_avg from t1 
group by maker, model
order by maker -- Тут просто выводим производителя, модель и минимальную, максимальную и среднюю цену по модели

--Задача 15

--Для производителей ноутбуков с самым большим размером экрана вывести список моделей всех выпускаемых типов устройств.
--Вывод: производитель, модель, цена. Упорядочить набор по возрастанию значения каждого поля.
with a_mx_screen as (select max(screen) mx_screen from laptop),

need_maker as
(select maker from
Products p join laptop lp on p.Model = lp.Model
where Screen in (select * from a_mx_screen)),

join_lp as (select maker, p.model, price from
Products p join laptop lp on p.Model = lp.Model
where maker in (select * from need_maker)),

join_pc as (select maker, p.model, price from
Products p join pc on p.Model = pc.Model
where maker in (select * from need_maker)),

join_pr as (select maker, p.model, price from
Products p join Printer pr on p.Model = pr.Model
where maker in (select * from need_maker)),

result as (select * from (
(select * from join_lp)
union
(select * from join_pc)
union
(select * from join_pr)) t)

select * from result
order by model

--Задача 16

with cca as (select id_psg,id_comp,date,time_out,town_to,town_from,place 
from Pass_in_trip join trip on Pass_in_trip.trip_no = trip.trip_no)

select passenger.name,company.name,time_out,town_to,town_from  
from cca inner join passenger on cca.Id_psg = Passenger.id_psg inner join company on Company.id_comp = cca.id_comp
where place like '%a' or place like '%d'

--Задача 17

/*Для пассажиров летавших только у окна вывести следующую информацию:
имя пассажира, количество полетов.*/
select distinct name, count(pit.trip_no) cnt_tr from Passenger psg
left join Pass_in_trip pit on pit.Id_psg = psg.Id_psg
where pit.place in (select place from Pass_in_trip pit where place like '_a' or place like '_b')
group by name

--Задача 18

/*Для всех городов из таблицы Trip посчитать количество вылетов и прилетов за апрель 2003 года.
Вывод: город, количество вылетов, количество прилетов*/
;with kk1 as (select pit.trip_no, count(pit.trip_no) cnt, town_from, town_to               
					from Pass_in_trip pit left join Trip tr on pit.trip_no = tr.trip_no     
					where date between '01.04.2003' and '30.04.2003'                       
					group by pit.trip_no, town_from, town_to)							   
select distinct tr.town_from, cnt_from, cnt_to											   
from Trip tr left join (select distinct town_from, sum(cnt) cnt_from 
						from kk1 
						group by town_from) t1 on tr.town_from = t1.town_from
			 left join (select distinct town_to, sum(cnt) cnt_to 
						from kk1 
						group by town_to) t2 on tr.town_from = t2.town_to
/*создаётся таблица kk1,
в которой хранятся: номера рейсов за апрель 2003 года,  
количество самих рейсов и инфа откуда-куда был совершен рейс.
Благодаря таблице kk1 снизу мы джоиним все города из таблицы Trip с таблицами
t1 (в ней хранится инфа по городам из которых был совершен рейс, а также количество этих рейсов)
и t2 (в ней хранится то же самое, что и в t1 только города в которые был совершен рейс) и выводим ответ:)*/


--Задача 19

--НЕТ

--Задача 20

--. Для каждой авиакомпании посчитать количество перевезенных пассажиров по типам самолетов.
--Вывод: название авиакомпании, тип самолета, количество перевезенных пассажиров


select name,plane,count(pas.Id_psg)количество_перевезенных_пассажиров from trip tr join Pass_in_trip pas on
tr.trip_no=pas.trip_no left join Company com on com.id_comp=tr.id_comp
where date !=0
group by name,plane

/* просто соединяю таблицы и группирую,
на некоторых самолетах люди не летали, это можно увидить из pass in trip b trip 
where date !=0 этой строкой вычетаются все самолеты, где людей нету */

--Задача 21

with pas_count as (
    select company.name,
    case when day([date]) % 2 = 1  then 1 end as even,
    case when day([date]) % 2 = 0  then 1 end as odd
    from Pass_in_trip
    join trip on Pass_in_trip.trip_no = Trip.trip_no
    join company on company.Id_comp = trip.Id_comp
)

select [name], count(even) pass_on_even, count(odd) pass_on_odd
from pas_count
group by [name]

--Задача 22

/*Для каждого типа самолета посчитать количество вылетов, совершенных в первую (понедельниксреда) и вторую (четверг-воскресенье) половины недели.
Вывод: тип самолета, количество вылетов в первую половину недели, количество вылетов во 
вторую половину недели*/
set dateformat dmy
select c1, c2, t2.plane
from(select count(datepart(dw,date)) as c1, plane
from Pass_in_trip pit join trip tr on pit.trip_no = tr.trip_no
where datepart(dw, date) < 4
group by plane) t1 
right join
(select count(datepart(dw,date)) as c2, plane
from Pass_in_trip pit join trip tr on pit.trip_no = tr.trip_no
where datepart(dw, date) > 3
group by plane) t2 on t1.plane = t2.plane


--Задача 23

--Для каждого города определить количество вылетов в первую (до 12:00:00) и вторую половину дня

DECLARE @time datetime = '1900-01-01 12:00:00.000'; 


select distinct trip.town_from, query_in_1.[Кол-во вылетов до 12], query_in_2.[Кол-во вылетов после 12] from trip 
left join 
(select town_from, count(town_from) as "Кол-во вылетов до 12" from trip -- левый джоин чтобы города не потерять
where time_out < @time
group by town_from)query_in_1 on query_in_1.town_from = Trip.town_from -- соединяю их по городу отправления из таблички trip
left join 
(select town_from, count(town_from) as "Кол-во вылетов после 12" from trip
where time_out > @time 
group by town_from)query_in_2 on query_in_2.town_from = Trip.town_from -- соединяю их по городу отправления из таблички trip

-----------------------------------------------------------------------------------------------------------------------------

select town_from, count(town_from) as "Кол-во вылетов до 12" from trip -- кол-во вылетов до 12
where time_out < @time -- Проверка времени
group by town_from


select town_from, count(town_from) as "Кол-во вылетов после 12" from trip -- кол-во вылетов после 12
where time_out > @time -- Проверка времени
group by town_from -- Группировка по городам

--Задача 24

select tn, name, town_from, town_to, cnt_fly, cnt_psg from
(
select trip_no tn, count(distinct date) cnt_fly, count(id_psg) cnt_psg from Pass_in_trip
group by trip_no
) t join trip on t.tn = trip.trip_no join Company on trip.Id_comp = Company.Id_comp

--Задача 25

/*Для каждого места определить количество перевезенных пассажиров по типам самолетов.
Вывод: тип самолета, место, количество перевезенных пассажиров.*/
select plane, place, count(id_psg) psg from pass_in_trip join trip on pass_in_trip.trip_no = trip.trip_no
group by place, plane

--Задача 26

/* Для рейсов, на которых одновременно летело более одного пассажира 
вывести: номер рейса, название авиакомпании, дата и время вылета, 
город вылета, город прилета. */

select pit.trip_no, name comp_name,		-- Джоиним таблицу trip (в ней находится большая часть необходимых
date, time_out, town_from, town_to   -- в условии данных) и company (для имени компании)
from pass_in_trip pit					-- и выбираем все значения из условия задачи
left join trip on trip.trip_no = pit.trip_no
left join company comp on comp.id_comp = trip.id_comp  -- company соединяется только с trip!

group by pit.trip_no, name, date,	-- Группируем по всем значениям подряд -_-
time_out, town_from, town_to		-- т.к. джоинили

having count(distinct id_psg) > 1		-- Считаем уникальных пассажиров и устанавливаем, чтобы их было > 1

/* Тут именно having, а не where, т.к. where не любит агрегатные функции (например, count). 
А having сначала группирует по условию, а потом уже отбирает получившиеся строки */

--Задача 27

/*Определить количество перевезенных пассажиров авиакомпаниями по месяцам и годам. 
Вывод: название авиакомпании, месяц, год, число перевезенных пассажиров. Упорядочить 
результат по возрастанию года и месяца и по убыванию числа пассажиров.*/
 select distinct name, ddty, ddtm, sum(c) over (partition by ddty, ddtm, name) as kolvo from Company cmp 
	join (select year(date + time_out) as ddty,   --- это таблица с годом и месяцами и с колвом пассажиров 
	MONTH(date + time_out) as ddtm, tr.Id_comp,   --- по каждому trip_no
	count(id_psg) as c from Pass_in_trip pit
	join Trip tr on pit.trip_no = tr.trip_no
	group by date, time_out, tr.Id_comp) as b on cmp.Id_comp = b.Id_comp
order by ddty, ddtm, kolvo desc

--- в общем запросе мы делаем сумму всех пассажиров из каждого trip_no по каждой компании и ордерим как в условии

--Задача 28

--Для каждого пассажира определить количество полетов по типам самолетов.
--Вывод: имя пассажира, тип самолета, количество перелетов этим типом самолета. Результат 
--упорядочить по именам пассажиров (в алфавитном порядке) и убыванию количества перелетов.


with t as (
select id_psg, plane, count(id_psg) cnt
from pass_in_trip
join trip on trip.trip_no = pass_in_trip.trip_no
group by id_psg, plane
)
--Вывод: имя пассажира, тип самолета, количество перелетов этим типом самолета
select name, plane, cnt from passenger
join t on passenger.id_psg = t.id_psg
order by name, cnt desc --упорядочить по именам пассажиров и убыванию количества перелетов

--Задача 29

/*Вывести список пассажиров, которые летели последним известным рейсом.
Вывод: номер рейса, название авиакомпании, имя пассажира, количество часов в полете*/
SELECT  pit.trip_no Номер_рейса, 
    com.name Название_авиакомпании, 
    pas.name Имя_пассажира, 
    24 - datediff (hh, time_in, time_out) Количество_часов_в_полете
FROM Pass_in_trip pit 
left join Passenger pas on pit.Id_psg = pas.Id_psg
left join Trip tr on pit.trip_no = tr.trip_no
left join Company com on tr.Id_comp = com.Id_comp
WHERE date = (select max(date) from Pass_in_trip)

--Задача 30

--Не готов
