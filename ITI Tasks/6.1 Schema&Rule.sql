Create database Agency

create table Department (DeptNo varchar(30),DeptName varchar(30),
Location varchar(30),constraint D_PK primary key (DeptNo))


CREATE RULE Loc_rule ​
AS @Loc ='NY'or @Loc ='DS'or @Loc ='KW'
sp_bindrule 'Loc_rule' ​, 'Department.Location'


insert into Department values ('d1','Research','NY')
,('d2','Accounting','DS'),('d3','Marketing','KW')

create table Employee (EmpNo int ,	EmpFname varchar(30) not null
,EmpLname varchar(30)not null,DeptNo varchar(30),Salary int,
constraint E_PK primary key (EmpNo),
constraint D_FK FOREIGN KEY (DeptNo) references Department (DeptNo),
constraint S_U Unique (Salary))

ALTER TABLE Employee
Add CONSTRAINT  D_FK FOREIGN KEY (DeptNo) references Department (DeptNo)

CREATE RULE Sal_rule ​
AS @Sal < 60000
sp_bindrule 'Sal_rule' ​, 'Employee.Salary'


INSERT INTO Employee (EmpNo, EMPFname, EMPLname, DeptNo, Salary)
VALUES 
(25348, 'Mathew', 'Smith', 'd3', 2500),
(10102, 'Ann', 'Jones', 'd3', 3000),
(18316, 'John', 'Barrimore', 'd1', 2400),
(29346, 'James', 'James', 'd2', 2800),
(9031,  'Lisa', 'Bertoni', 'd2', 4000),
(2581,  'Elisa', 'Hansel', 'd2', 3600),
(28559, 'Sybl', 'Moser', 'd1', 2900);

create table Project (ProjectNo varchar(30) not null 
, ProjectName varchar(30) not null, Budget int
,constraint P_PK primary key (ProjectNo))


INSERT INTO Project (ProjectNo, ProjectName, Budget)
VALUES 
('p1', 'Apollo', 120000),
('p2', 'Gemini', 95000),
('p3', 'Mercury', 185600);

 
-- Create the table
CREATE TABLE Works_on (
    EmpNo INT,
    ProjectNo VARCHAR(30),
    Job VARCHAR(50),
    Enter_Date DATE NOT NULL DEFAULT getdate(),
    PRIMARY KEY (EmpNo, ProjectNo),

);

ALTER TABLE Works_on
ALTER COLUMN ProjectNo VARCHAR(30) NULL

-- Insert multiple rows in one INSERT statement
INSERT INTO Works_on (EmpNo, ProjectNo, Job, Enter_Date) VALUES
(10102, 'p1', 'Analyst', '2006-10-01'),
(10102, 'p3', 'Manager', '2012-01-01'),
(25348, 'p2', 'Clerk', '2007-02-15'),
(18316, 'p2', NULL, '2007-06-01'),
(29346, 'p2', NULL, '2006-12-15'),
(2581,  'p3', 'Analyst', '2007-10-15'),
(9031,  'p1', 'Manager', '2007-04-15'),
(28559, 'p1', NULL, '2007-08-01'),
(28559, 'p2', 'Clerk', '2012-02-01'),
(9031,  'p3', 'Clerk', '2006-11-15'),
(29346, 'p1', 'Clerk', '2007-01-04');

ALTER TABLE Works_on
Add CONSTRAINT  W_FK FOREIGN KEY (EmpNo) references employee (EmpNo)

ALTER TABLE Works_on
Add CONSTRAINT  PR_FK FOREIGN KEY (ProjectNo) references project (ProjectNo)


--
INSERT INTO Works_on (EmpNo, ProjectNo)
VALUES (11111, 'p1');
--The INSERT statement conflicted with the FOREIGN KEY constraint...

UPDATE Works_on
SET EmpNo = 11111
WHERE EmpNo = 10102;
--The UPDATE statement conflicted with the FOREIGN KEY constraint...

UPDATE Employee
SET EmpNo = 22222
WHERE EmpNo = 10102;
--The UPDATE statement conflicted with the FOREIGN KEY constraint...

DELETE FROM Employee
WHERE EmpNo = 10102;
--The DELETE statement conflicted with the REFERENCE constraint "W_FK". 

ALTER TABLE Employee
ADD TelephoneNumber VARCHAR(20);

ALTER TABLE Employee
DROP COLUMN TelephoneNumber;
 

CREATE SCHEMA Company
CREATE SCHEMA HumanResource

ALTER SCHEMA Company TRANSFER dbo.Department;
ALTER SCHEMA Company TRANSFER dbo.Project;
ALTER SCHEMA HumanResource TRANSFER dbo.Employee;


EXEC sp_helpconstraint 'HumanResource.Employee';

CREATE SYNONYM Emp FOR HumanResource.Employee;

Select * from Employee
Select * from HumanResource.Employee
Select * from Emp
Select * from HumanResource.Emp
--Invalid object name 'HumanResource.Emp'.



UPDATE Project
SET Budget = Budget * 1.10
WHERE ProjectNo = 10102; -- EMP 


UPDATE Company.Department
SET DeptName = 'Sales'
WHERE DeptNo = (
    SELECT DeptNo
    FROM [HumanResource].[Employee]
    WHERE EmpFname = 'James'
);


UPDATE Works_On
SET Enter_Date = '2007-12-12'
WHERE ProjectNo IN (
    SELECT DISTINCT W.ProjectNo
    FROM Works_On W
    JOIN [HumanResource].Employee E ON W.EmpNo = E.EmpNo
    JOIN Company.Department D ON E.DeptNo = D.DeptNo
    WHERE W.ProjectNo= 'P1' AND D.DeptName = 'Sales'
);

DELETE FROM Works_On
WHERE EmpNo IN (
    SELECT E.EmpNo
    FROM [HumanResource].Employee E
    JOIN Company.Department D ON E.DeptNo = D.DeptNo
    WHERE D.Location = 'KW'
);

