/*
  CREATE TABLE Employee (
 	id int,
  	name varchar(255),
  	salary int,
  	departmentId int,
  	PRIMARY KEY (id)
  )
  
  
  INSERT INTO Employee(id, name, salary, departmentid) VALUES 
    (1, 'Sam', 6000, 1)
    , (2, 'Max', 8000, 1)
    , (3, 'Haley', 8000, 1)
    , (4, 'Wendy', 9000, 1)
    , (5, 'Noey', 7000, 1)
    , (6, 'Will', 9000, 1)
    , (7, 'Randy', 8500, 1)
    , (8, 'Nashi', 12000, 2)
    , (9, 'Henry', 12500, 2)
    , (10, 'Athur', 11000, 2)
    , (11, 'Welly', 12500, 2)
    , (12, 'Jenny', 11500, 2)
    , (13, 'Miu', 2000, 3)
    , (14, 'Thor', 5000, 3)
    , (15, 'Jack', 4000, 3)
    , (16, 'Joey', 3000, 3)
    
    
CREATE TABLE Department(
	id int,
	name varchar(255)
  	PRIMARY KEY(id)
  )
INSERT INTO Department(id, name) VALUES (1, 'IT'), (2, 'Sales'), (3, 'Marketing')
    */


SELECT * from Employee;
SELECT * from Department;

/*Q1: SELECT TOP HIGHEST OF EACH DEPARTMENT*/


-- S1: Use of window_function
---> Use DENSE_RANK
SELECT d.name as Department, x.salary, x.name 
FROM (
  SELECT name, salary, departmentid, dense_rank() over(PARTITION BY departmentid order by salary DESC) as 'Dense_Rank'
	FROM Employee
) x
JOIN Department d 
ON x.departmentid = d.id
WHERE x.Dense_Rank = 1
ORDER by x.departmentid, x.Dense_Rank

---> Use ROW_NUMBER
SELECT d.name as Department, x.salary, x.name 
FROM (
  SELECT name, salary, departmentid, row_number() over(PARTITION BY departmentid order by salary DESC) as 'Row_Number'
	FROM Employee
) x
JOIN Department d 
ON x.departmentid = d.id
WHERE x.Dense_Rank = 1
ORDER by x.departmentid, x.row_number

-- S2: Use of group by then use max aggregation
SELECT d.name, x.max_salary_by_department, e.name
FROM Employee e
JOIN Department d ON e.departmentid = d.id
JOIN (
  	SELECT departmentid, max(salary) as max_salary_by_department
	from Employee e
	GROUP by departmentid 
) x
on e.departmentid = x.departmentid and e.salary = x.max_salary_by_department

-- S3: Use IN function in MSSQL -- SQL Sever
SELECT name, salary, departmentid
FROM Employee
WHERE concat(departmentid, salary) IN (
	SELECT concat(departmentid, max(salary)) as concat_max_salary_w_department
  	FROM Employee e 
  	GROUP by departmentid
)
/*-- This S3 use two column in IN operaton can only apply for MySQL
SELECT *
FROM Employee e1
WHERE (e1.departmentid, e1.salary) IN (
	SELECT departmentid, max(salary) as max_salary_by_department
  	FROM Employee e2
  	GROUP by departmentid
)*/

-- S4: Use usual WHERE condition using by MAX or TOP
SELECT *
FROM Employee e1
WHERE salary = (SELECT Max(x.salary)
                FROM   (SELECT *
                        FROM   Employee e2
                        WHERE  e1.departmentid = e2.departmentid) x);
        
SELECT *
FROM Employee e1
WHERE salary = (SELECT TOP(1) salary as salary
                FROM Employee e2
                WHERE e1.departmentid = e2.departmentid
                ORDER BY salary DESC)
/*
SELECT *
FROM employees
WHERE salary = (SELECT MAX(salary) FROM employees);
--> Simple explain for S4*/   

-- S5: Working with Join Table and NULL Values
SELECT department, name, salary FROM 
    (
      SELECT e1.departmentId as Department, e1.name as name, e1.salary as salary, e2.salary as salary_e2
      from Employee e1
      LEFT JOIN Employee e2
      ON e1.departmentId = e2.departmentid AND e1.salary < e2.salary
	) x
where x.salary_e2 is null

-- S6: Working with Left Join Table and COUNT
SELECT e1.departmentId as department, e1.name, e1.salary as salary
from Employee e1
LEFT JOIN Employee e2
ON e1.departmentId = e2.departmentid AND e1.salary < e2.salary
group by e1.departmentId, e1.name, e1.salary
having COUNT(DISTINCT e2.salary) = 0



/*Q2: SELECT TOP SECOND OF EACH DEPARTMENT*/

-- S1: Using Max function
SELECT e.departmentid, e.name, e.salary
from Employee e
JOIN (
        SELECT e1.departmentId as departmentId,  Max(e1.salary) as second_salary
        from Employee e1
        WHERE e1.salary NOT IN ( SELECT TOP(1) e2.salary 
                               from Employee e2
                               WHERE e1.departmentId = e2.departmentId
                               ORDER by e2.salary DESC)
        group by e1.departmentId
  	) x
ON e.departmentId = x.departmentId and e.salary = x.second_salary
ORDER by e.departmentId

-- S2: Using DENSE_RANK window function
SELECT departmentid, name, salary 
FROM
  (
      SELECT departmentid, name, salary, dense_rank() over(partition by departmentid order by salary DESC) as den_rank
      from Employee
  )x
WHERE x.den_rank = 2

-- S3: Using COUNT & HAVING
SELECT e1.departmentid, e1.salary, e1.name
FROM Employee e1
JOIN Employee e2
on e1.salary < e2.salary and e1.departmentid = e2.departmentid
group by e1.departmentid, e1.salary, e1.name
HAVING COUNT(DISTINCT e2.salary) = 1
    













  