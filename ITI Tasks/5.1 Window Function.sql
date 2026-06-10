--1
--Retrieve number of students who have a value in their age.
select count(st_id) from Student where st_age is not null

--2
--Get all instructors Names without repetition 
select distinct Ins_Name from Instructor

--3
--Display student with the following Format (use isNull function)
SELECT  
    s.St_id AS Student_ID,  
    ISNULL(s.St_Fname, 'Unknown') + ' ' + ISNULL(s.St_Lname, ' ') AS Student_FULL_name,
    d.Dept_Name
FROM Student s
JOIN Department d ON s.Dept_Id = d.Dept_Id;

--4
--Display instructor Name and Department Name  
--Note: display all the instructors if they are attached to a department or not 

select  I.Ins_Name , D.dept_name
from Instructor I left join Department D on I.Dept_Id = D.Dept_Id

--5
--Display student full name and the name of the course he is taking 
--For only courses which have a grade   
SELECT  
    s.St_Fname +' '+ s.St_Lname as Full_name ,  o.Crs_name
FROM Student s ,Stud_Course c , Course o
where s.St_Id = c.St_Id and o.Crs_Id  = c.Crs_Id
and c.grade is not null
;


--6
--Display number of courses for each topic name
SELECT  
  t.Top_Name ,  count(o.Crs_Id)
FROM Topic t , Course o
where t.Top_Id = o.Top_Id
group by t.Top_Name 

--7
-- Display max and min salary for instructors 
select max(Salary) , min(Salary) from Instructor
where Salary is not null

--8
--Display instructors who have salaries less than the average salary of all instructors. 
select Ins_Name from Instructor
where Salary < (select avg(Salary) from Instructor )



--9
--Display the Department name that contains the instructor who receives the minimum salary. 
select  D.dept_name 
from Instructor I , Department D 
where  I.Dept_Id = D.Dept_Id  and salary = (select min(salary) from Instructor)
--group by d.Dept_Name ,Salary
--having Salary = min(Salary)

--10
--Select max two salaries in instructor table.
select  top 2 Salary
from Instructor
order by Salary

--11
--Select instructor name and his salary but if there is no salary display instructor bonus keyword. “use coalesce Function” 

SELECT 
    Ins_Name, 
    COALESCE(Convert(VARCHAR(10) ,Salary), 'Bonus') AS Salary_or_Bonus
FROM Instructor;

--12
--Select Average Salary for instructors  
select  avg(Salary)
from Instructor



--13
--Select Student first name and the data of his supervisor  
select s.st_fname  , s.St_super , u.st_fname  ,u.St_Address,u.St_Age,u.St_Lname 
from Student s , Student u 
where u.st_id = s.St_super

--14
--Write a query to select the highest two salaries in Each Department for instructors 
--who have salaries. “using one of Ranking Functions” 

SELECT *
FROM (
    SELECT I.Ins_Name,D.Dept_Name, I.Salary,
    ROW_NUMBER() OVER (PARTITION BY D.Dept_Name ORDER BY I.Salary DESC) AS RowNum
    FROM Instructor I
    JOIN Department D ON I.Dept_Id = D.Dept_Id
    WHERE I.Salary IS NOT NULL
) AS RankedSalaries
WHERE RowNum <= 2;

--15
--Write a query to select a random  student from each department.  
--“using one of Ranking Functions” 


SELECT *
FROM (
    SELECT S.St_id,S.St_Fname + ' ' + S.St_Lname AS Student_Name, D.Dept_Name,
        ROW_NUMBER() OVER (PARTITION BY D.Dept_Name ORDER BY NEWID()) AS RandomRank
    FROM Student S
    JOIN Department D ON S.Dept_Id = D.Dept_Id
) AS RankedStudents
WHERE RandomRank = 1;


 
