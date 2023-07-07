/*
--https://www.youtube.com/watch?v=LZGaRcDxj8I&ab_channel=techTFQ
*/

CREATE TABLE Hierarchical
(
    emp_id [NVARCHAR](50),
    reporting_id [NVARCHAR](50)
    -- specify more columns here
);

insert into Hierarchical(emp_id, reporting_id) 
values (1, null), (2, 1), (3, 1), (4, 2), (5, 2), (6, 3), (7, 3), (8, 4), (9, 4);


select * from Hierarchical;

with cte as (
	select emp_id, emp_id as emp_hierachy from Hierarchical
	union all
	select cte.emp_id, h.emp_id as emp_hierachy
	from cte
	join Hierarchical h on cte.emp_hierachy = h.reporting_id
	)

select * from cte where emp_id <> emp_hierachy order by emp_id 

-- 1st Interation:
select emp_id, emp_id as emp_hierachy from Hierarchical where emp_id = 1;

-- 2st Interation:
select cte.emp_id, h.emp_id as emp_hierachy
from (	select emp_id, emp_id as emp_hierachy 
		from Hierarchical 
		where emp_id = 1) cte
join Hierarchical h on cte.emp_id = h.reporting_id

-- 3st Interation:
select cte.emp_id, h.emp_id as emp_hierachy
	from (
				select cte.emp_id, h.emp_id as emp_hierachy
				from (	select emp_id, emp_id as emp_hierachy 
						from Hierarchical 
						where emp_id = 1) cte
				join Hierarchical h on cte.emp_id = h.reporting_id
	)cte
join Hierarchical h on cte.emp_hierachy = h.reporting_id
