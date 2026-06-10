--13
--Insert your personal data to the employee table as a new employee in 
--department number 30, SSN = 102672, Superssn = 112233, salary=3000.

insert into Employee 
values('Sondos','Mohamed',102672, '1-10-2003' ,' 15 tharwat street ,Suez','F',
3000,112233,30)

--14
--Insert another employee with personal data your friend as new employee in
--department number 30, SSN = 102660, 
--but don’t enter any value for salary or supervisor number to him.

insert into Employee 
values('Gharam','Said',102660, '6-24-2002' ,' 15 Horia street ,Adly','F',
null,null,30)

insert into Employee (fname,lname,ssn,bdate,address,sex,dno)
values('Gharam','Said',10260, '6-24-2002' ,' 15 Horia street ,Adly','F',30)


--15
--Upgrade your salary by 20 % of its last value

UPDATE Employee
SET Salary += 0.2 * Salary
where ssn = 102672

UPDATE Employee
SET Salary += 0.2 * Salary
where Fname = 'Sondos'




--1 
-- Display (Using Union Function)
--a.The name and the gender of the dependence that's gender is Female 
-- and depending on Female Employee.
--b.And the male dependence that depends on Male Employee.

select D.Dependent_name,D.sex from Dependent D join Employee E
where D.sex='F'AND E.sex ='F'
union 
select D.Dependent_name,D.sex from Dependent DjoinEmployee E
where D.sex='M'AND E.sex ='M'

--2
-- For each project, list the project name and the total hours per week 
--(for all employees) spent on that project.

SELECT Pname , SUM(Hours) from Project , Works_for
where pno = Pnumber
group by Pname
 
--3
--Display the data of the department 
--which has the smallest employee ID over all employees' ID.

SELECT D.Dname, D.Dnum, D.MGRSSN, D.[MGRStart Date]
FROM Departments D
JOIN Employee E ON D.Dnum = E.Dno
WHERE E.SSN = (
    SELECT MIN(SSN)
    FROM Employee
    WHERE Dno IS NOT NULL
);



--4
--For each department, retrieve the department name and the maximum, 
--minimum and average salary of its employees. (Done) 
SELECT dname,max(Salary),min(Salary) ,avg(Salary)
from Departments,Employee 
where dno = dnum 
group by dname



--5 
--List the full name of all managers who have no dependents. (Done) 

select  Fname  +' '+ lname as full_name from Employee -- managers
except
select Fname +' '+ lname as full_name from Employee ,Dependent  , Departments
where MGRSSN = SSN and ESSN = MGRSSN

--6
--For each department-- if its average salary is less than the average salary of all employees
-- display its number, name and number of its employees. (Done) 

Select  Dnum, dname ,count(SSN) 
from Employee ,Departments
where Dno = Dnum 
group by Dnum, dname
having AVG(Salary) < 
(select AVG(Salary) 
from employee 
)

--7
--Retrieve a list of employees names and the projects names they are working on 
--ordered by department number and within each department, 
--ordered alphabetically by last name, first name. (Done) 

select dno ,fname,lname ,Pname 
from Employee , Works_for ,Project
where SSN = ESSN and Pno=Pnumber
order by dno , Lname,Fname 

--8
--Try to get the max 2 salaries using subquery (Done)
SELECT Top 2  Salary 
from Employee 
where Salary in (SELECT Salary 
from Employee 
where Salary is not null 
)
order by Salary desc

--9
--Get the full name of employees that is similar to any dependent name (Done) 
select Fname + lname as full_name 
from Employee 
where  Fname + lname in
(select Dependent_name
from Dependent
)

--10 
--Display the employee number and name 
--if at least one of them have dependents (use exists keyword) self-study. (Done) 
select  ssn , Fname + ' '+lname as full_name 
from Employee join
where EXISTS(select	1 from Dependent -- 
where SSN = ESSN )

--11
--In the department table insert new department called "DEPT IT" , with id 100,
--employee with SSN = 112233 as a manager for this department. 
--The start date for this manager is '1-11-2006' (Done) 
insert into Departments 
values('DEPT IT',100,112233, '1-11-2006' )

--12
--Do what is required if you know that : Mrs.Noha Mohamed(SSN=968574)  
--moved to be the manager of the new department (id = 100), and 
--they give you(your SSN =102672) her position (Dept. 20 manager)  (Done) 

--First try to update her record in the department table 
--Update your record to be department 20 manager. 
--Update the data of employee number=102660 to be in your teamwork
--(he will be supervised by you) (your SSN =102672) 

Update Departments 
set MGRSSN = 968574 ,[MGRStart Date] ='7-26-2025'  
where dnum = 100
Update Departments 
set MGRSSN = 102672 ,[MGRStart Date] ='7-26-2025'  
where dnum = 20
Update Employee
set Superssn = 102672 ,Dno = 20
where SSN = 102660
 
 --13
--Unfortunately the company ended the contract with Mr. Kamel Mohamed (SSN=223344) so 
--try to delete his data from your database in case you know that you will be temporarily 
--in his position. 

--Hint: (Check if Mr. Kamel has dependents, works as a department manager, supervises 
--any employees or works in any projects and handle these cases). 


update Employee set Superssn = 102672 where Superssn = 223344
update Departments set MGRSSN = 102672 where MGRSSN = 223344 --
delete from Works_for where ESSN = 223344 
delete from Dependent where ESSN = 223344
delete from Employee where SSN = 223344
--14
--Try to update all salaries of employees who work in Project ‘Al Rabwah’ by 30% 
Update Employee
set Salary += Salary * 0.3 
where ssn in (
select ESSn from Project,Works_for
where Pno = Pnumber AND Pname='Al Rabwah')
