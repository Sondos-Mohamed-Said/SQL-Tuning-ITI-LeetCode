--1
select Dnum, Dname ,Fname ,Lname ,ssn 
from Departments,Employee
where  MGRSSN = ssn 
 --2
select Dname ,Pname 
from Departments D,Project P
where D.Dnum  = P.Dnum

 --3
select d.Dependent_name,d.Sex,d.Bdate, e.Fname ,e.Lname 
from Employee e, Dependent d
where e.ssn =d.ESSN
 
 --4
select Pnumber, Pname ,Plocation 
from Project
where City = 'Cairo' or City = 'Alex'   

 --5
select * from Project
where Pname like 'a%'

 --6
select Fname,Lname ,dno , Salary
from Employee
where Dno = 30 and (Salary between 1000 and 2000)

--7 
select Fname  from Project , Employee, Works_for

where ESSn = ssn and Pnumber = pno and dno = 10
and hours >= 10 and  Pname = 'AL Rabwah'

 --8
select e.Fname,e.Lname , s.Fname,s.Lname
from Employee e , Employee s
where e.Superssn = s.SSN and
s.Fname = 'Kamel' and 
s.Lname = 'Mohamed'

 --9
select  Fname ,Pname from Project , Employee, Works_for
where ESSn = ssn and Pnumber = pno
order by Pname

 --10
select P.Pnumber , D.Dname , E.Lname ,E.Address,E.Bdate
from Project P , Departments D ,Employee E
where P.Dnum = D.Dnum and D.MGRSSN = E.ssn and City = 'Cairo' 

 
--11
select s.Fname,s.Lname,s.Address,s.Bdate,s.Salary,
s.Sex,s.SSN,s.Superssn
from Departments D ,Employee s
where  D.MGRSSN = s.ssn 

 --12
select s.Fname,s.Lname,s.Address,s.Bdate,s.Salary,
s.Sex,s.SSN,s.Superssn , D.Dependent_name,D.Sex ,D.Bdate
from Employee s left join Dependent  D on s.SSN = D.ESSN 
