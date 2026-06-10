--1
Select * from Employee
--2
Select Fname, Lname, Salary ,Dno from Employee 
--3
Select Pname,Plocation,Dnum from Project --name d
--4
Select Fname +' '+ Lname  AS Full_name , Salary,  0.1 * Salary * 12  AS ANNUAL_COMM 
from Employee 
--5
Select SSN ,Fname +' '+ Lname  AS Full_name 
from Employee 
where Salary > 1000
--6
Select SSN ,Fname +' '+ Lname  AS Full_name 
from Employee 
where Salary*12 > 10000
--7
Select Fname +' '+ Lname  AS Full_name 
from Employee 
where Sex = 'F'
--8
Select Dnum,Dname
from Departments
where MGRSSN = 968574
--9
Select Pnumber, Pname,Plocation from Project Where Dnum = 10 --name d
