create database batch_wh
/*
-- DATABASE
	create table batch (
		batch_id varchar(10) not null,
		quantity int,
		primary key(batch_id)
	)
	insert into batch(batch_id, quantity) values ('B1',5), ('B2',12), ('B3',8)

	create table orders (
		order_id varchar(10) not null,
		quantity int,
		primary key(order_id)
	)
	insert into orders(order_id, quantity) values ('O1',2), ('O2',8), ('O3',2), ('O4',5), ('O5',9) ,('O6',5)

"Imagine a warehouse where the available items are stored as per different batches as indicated in the BATCH table.
Customers can purchase multiple items in a single order as indicated in ORDERS table.

Write an SQL query to determine items for each order are taken from which batch. 
Assume that items are sequencially taken from each batch starting from the first batch."																												

*/

select * from batch;
select * from orders;


/*
-- SOLUTION 1:
Step 1: Split all record of two table batch and orders with recursive
Step 2: Then get row number by using row_number function
Step 3: Left join two table and then group by them based on row_num 
Step 4: It's has one prolem is still show values of null
*/

with batch_split as (
		select batch_id, 1 as quantity from batch
		union all 
		select b.batch_id, cte.quantity + 1
		from batch_split cte
		join batch b on b.batch_id = cte.batch_id and cte.quantity < b.quantity
	)
	, orders_split as (
		select order_id, 1 as quantity from orders
		union all 
		select o.order_id, cte.quantity + 1
		from orders_split cte
		join orders o on o.order_id = cte.order_id and cte.quantity < o.quantity
	)
	
select t1.order_id, t2.batch_id, count(t1.order_id) as quantity
from 
	(select order_id, 1 as quantity, row_number() over(order by order_id) as row_num from orders_split order by 1,2 offset 0 rows) t1 
left join (select batch_id, 1 as quantity, row_number() over(order by batch_id) as row_num from batch_split order by 1,2 offset 0 rows) t2
on t1.row_num = t2.row_num
group by t1.order_id, t2.batch_id
order by 1, 2;







-- declare @table_temp table (order_id varchar(10), qty_order int, batch_id varchar(10), qty_batch int, free int, needmore int);



declare @table_temp table (order_id varchar(10), qty_order int, batch_id varchar(10), qty_batch int);

insert into @table_temp select * from 
	(	select  order_id, o.quantity as qty_order, batch_id, t1.quantity as qty_batch
		from orders  o 
		cross join (select top(1) batch_id, quantity from batch) t1
	) table_temp;
select *,
	case 
		when qty_order < qty_batch then 0 else qty_order - qty_batch end as needmore,
		qty_batch - qty_order as free
from @table_temp



declare @number int;
set @number = 1;

while (@number < 2)
begin 
	declare @table_batch table(row_num int, batch_id varchar(10), qty_batch int)
	insert into @table_batch select row_number() over( order by batch_id) as row_num, *  from batch
	
	declare @table_orders table(row_num int, order_id varchar(10), qty_order int)
	insert into @table_orders select row_number() over( order by order_id) as row_num, *  from orders
	
	declare @count_row int;
	set @count_row = 1;
	
	select *,
		case
			when t1.qty_order < t2.qty_batch then 0 end as need_more
	from 
	(select * from @table_orders t1 where row_num = @count_row) t1
	cross join @table_batch t2

	

	
	set @number = @number + 1
end


select * from batch;

