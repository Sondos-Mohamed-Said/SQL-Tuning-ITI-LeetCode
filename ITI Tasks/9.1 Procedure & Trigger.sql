--1
--Create a stored procedure without parameters to show the number of 
--students per department name.[use ITI DB]  
CREATE PROCEDURE P1
AS 
SELECT Dept_Name, count(st_id) 
from student s join Department d 
on s.Dept_Id = d.Dept_Id
group by Dept_Name

exec P1

--2
-- a stored procedure that will check for the # of employees in the project p1
--if they are more than 3 print message to the user “'The number of employees 
--in the project p1 is 3 or more'” if they are less display a message to the user 
--“'The following employees work for the project p1'” in addition to the first name 
--and last name of each one .[Company DB] Create 


alter PROCEDURE P2
AS 
begin
declare @num int;

	SELECT @num = count(e.SSN) 
	from hr.Employee e join Works_for w   
	on e.ssn = w.ESSn
	join Project p
	on w.pno = p.Pnumber
	where p.Pname = 'P1'

	if @num >= 3
	print'The number of employees in the project p1 is 3 or more'
	else 
	PRINT 'The following employees work for the project p1';

        SELECT e.Fname, e.Lname
        FROM hr.Employee e
        JOIN Works_for w 
            ON e.SSN = w.ESSn
        JOIN Project p 
            ON w.Pno = p.Pnumber
        WHERE p.Pname = 'P1';
end

exec P2




--Create a stored procedure that will be used in case there is an old employee 
--has left the project and a new one become instead of him. The procedure should 
--take 3 parameters (old Emp. number, new Emp. number and the project number)
--and it will be used to update works_on table. [Company DB] 


CREATE PROCEDURE P3 (@old_id int ,@new_id int,@pnum int)
AS 
begin
	UPDATE Works_for 
	SET essn = @new_id 
	where ESSn = @old_id and pno = @pnum
end

exec P3 1,2,2



--4
	ALTER table Project 
	add budget int

	CREATE TABLE ProjectBudgetAudit (
    ProjectNo   VARCHAR(10),
    UserName    NVARCHAR(100),
    ModifiedDate DATETIME,
    Budget_Old  int,
    Budget_New  int
);

CREATE TRIGGER trg_AuditBudget
ON Project
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Budget)
    BEGIN
        INSERT INTO ProjectBudgetAudit (ProjectNo, UserName, ModifiedDate, Budget_Old, Budget_New)
        SELECT 
            i.Pnumber,                      -- Project number
            SUSER_SNAME(),                  -- User who made the change
            GETDATE(),                      -- Modification date
            d.Budget,                       -- Old budget
            i.Budget                        -- New budget
        FROM inserted i
        JOIN deleted d ON i.Pnumber = d.Pnumber;
    END
END;




--5
--Create a trigger to prevent anyone from inserting a new record in the Department table [ITI DB] 
--“Print a message for user to tell him that he can’t insert a new record in that table” 
CREATE TRIGGER PREV_INSERT
ON DEPARTMENT
INSTEAD OF INSERT
AS
BEGIN
	PRINT 'can’t insert a new record in that table'
END

--6
--Create a trigger that prevents the insertion Process for Employee table in March [Company DB]. 

CREATE TRIGGER PREV_INSERT_M
ON HR.EMPLOYEE
AFTER INSERT
AS
BEGIN
    IF MONTH(GETDATE()) = 3
    BEGIN
        RAISERROR('Inserting employees in March is not allowed.', 16, 1); 
        ROLLBACK TRANSACTION; -- cancel insert
    END
END;

-- anthor ans
CREATE TRIGGER trg_PreventInsertInMarch
ON HR.Employee
INSTEAD OF INSERT
AS
BEGIN
    IF MONTH(GETDATE()) = 3
    BEGIN
        RAISERROR('Inserting employees in March is not allowed.', 16, 1);
        RETURN; -- Stop without inserting
    END

    -- Insert normally if not March
    INSERT INTO Employee (SSN, Fname, Lname, Address, Salary, Dno)
    SELECT SSN, Fname, Lname, Address, Salary, Dno
    FROM inserted;
END;

--7
CREATE TABLE Student_Audit (
    ServerUserName NVARCHAR(128),
    [Date] DATETIME,
    Note NVARCHAR(400)
);

CREATE TRIGGER trg_Student_Audit_Insert
ON student
AFTER INSERT
AS
BEGIN
  

    INSERT INTO Student_Audit (ServerUserName, [Date], Note)
    SELECT 
        SUSER_SNAME(), 
        GETDATE(),
        CONCAT(
            SUSER_SNAME(),
            ' Insert New Row with Key=',
            CAST(i.St_Id AS NVARCHAR(50)),
            ' in table student'
        )
    FROM inserted i;
END;

select * from Student_Audit 

--8
--Create a trigger on student table instead of delete to add Row in Student Audit
--table (Server User Name, Date, Note) where note will be “ try to delete Row with Key=[Key Value]”
CREATE TRIGGER trg_Student_Audit_Delete
ON student
INSTEAD OF DELETE
AS
BEGIN

    INSERT INTO Student_Audit (ServerUserName, [Date], Note)
    SELECT 
        SUSER_SNAME(),                         
        GETDATE(),                             
        'try to delete Row with Key=' + CAST(d.St_ID AS NVARCHAR(50))
    FROM deleted d; 
END;
