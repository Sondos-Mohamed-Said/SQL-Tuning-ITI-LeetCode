--1
--Create a view that displays student full name, course name if the student 
--has a grade more than 50. 

create view V1(student_name,course_name)
as
	select st_fname +' '+ st_lname  ,crs_Name
	from student s 
	join  Stud_Course st on st.St_Id = s.St_Id
	join course c on st.Crs_Id = c.Crs_Id 
	where st.grade > 50

--2
--Create an Encrypted view that displays manager names and the topics they teach. 

CREATE VIEW dbo.vw_ManagerTopics(N,T)

AS
SELECT 
    i.Ins_Name AS ManagerName,
    t.Top_Name AS TopicName
FROM 
    Instructor i
JOIN 
    Ins_Course ic ON i.Ins_Id = ic.Ins_Id
JOIN 
    Course c ON ic.Crs_Id = c.Crs_Id  
JOIN 
    Topic t ON c.Top_Id = t.Top_Id;   

--3
--Create a view that will display Instructor Name, 
--Department Name for the ‘SD’ or ‘Java’ Department 
create view V2(Instructor_Name,Department_Name)
as
	select ins_name,dept_Name
	from instructor i
	join  department d on d.dept_Id = i.dept_id
	where d.dept_name in ('SD','JAVA')

SELECT * FROM V3
--4
--Create a view “V1” that displays student data for student who lives in Alex or Cairo. 
--Note: Prevent the users to run the following query 
--Update V1 set st_address=’tanta’
--Where st_address=’alex’;

create view V3
as
	select *
	from student 
	Where St_Address in ('Cairo','Alex')
	With check option

UPDATE V3
SET st_address = 'Tanta' 
WHERE st_address = 'Alex';
--The attempted insert or update failed because the target view either specifies WITH CHECK OPTION

--4
--Create a view that will display the project name and the number 
--of employees work on it. “Use Company DB”

create view V4 (project_name , number_of_employees)
as
	select Pname , count(ESSn)
	from Project join Works_for
	on Pno = Pnumber
	group by Pname

select * from  v4

--5
--Create index on column (Hiredate) that allow u to cluster the data in table Department. What will happen?
create  clustered index i1 on Department(Manager_hiredate)
--error
--Cannot create more than one clustered index on table 'Department'

--6
--Create index that allow u to enter unique ages in student table. What will happen?
create unique index u1 on student(st_age)
--error
--The CREATE UNIQUE INDEX statement terminated because a duplicate key was found

--7
--Using Merge statement between the following two tables
--[User ID, Transaction Amount] (Daily Amount) , (User Balance)

CREATE TABLE DailyTransactions (
    UserID INT,
   TransactionAmount INT
);

INSERT INTO DailyTransactions (UserID,TransactionAmount)
VALUES
    (1, 1000),
    (2, 1500),
    (3,  2000);

	CREATE TABLE LastTransactions (
      UserID INT,
   TransactionAmount INT
);

INSERT INTO LastTransactions (UserID, TransactionAmount)
VALUES
    (1,  800),
    (2, 1500),
    (4,  1700);

MERGE INTO LastTransactions AS Target
USING DailyTransactions AS Source
ON Target.UserID = Source.UserID

WHEN MATCHED THEN
    UPDATE SET Target.TransactionAmount = Target.TransactionAmount + Source.TransactionAmount

WHEN NOT MATCHED BY TARGET THEN
    INSERT (UserID, TransactionAmount)
    VALUES (Source.UserID, Source.TransactionAmount);


select * from DailyTransactions
select * from LastTransactions 

--8 Display Course Name , Student Full Name with Grade
--In each course with name of leading student and lag student in each course


SELECT 
    C.Crs_Name,
    S.St_Fname + ' ' + S.St_Lname AS Student_Full_Name,
    SC.Grade,
    FIRST_VALUE(S.St_Fname + ' ' + S.St_Lname) OVER (PARTITION BY C.Crs_Id ORDER BY SC.Grade DESC) AS Leading_Student,
    LAST_VALUE(S.St_Fname + ' ' + S.St_Lname) OVER (PARTITION BY C.Crs_Id ORDER BY SC.Grade DESC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS Lagging_Student
FROM 
    Stud_Course SC
JOIN 
    Student S ON SC.St_Id = S.St_Id
JOIN 
    Course C ON SC.Crs_Id = C.Crs_Id;






