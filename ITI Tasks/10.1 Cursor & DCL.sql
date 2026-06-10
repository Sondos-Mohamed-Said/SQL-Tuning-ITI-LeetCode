--1
DECLARE @SSN INT, 
        @Salary DECIMAL(10,2);

DECLARE Salary_Cursor CURSOR FOR
SELECT SSN, Salary
FROM HR.Employee;

OPEN Salary_Cursor;

FETCH NEXT FROM Salary_Cursor INTO @SSN, @Salary;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @Salary < 3000
    BEGIN
        UPDATE HR.Employee
        SET Salary = Salary * 1.10
        WHERE SSN = @SSN;
    END
    ELSE
    BEGIN
        UPDATE HR.Employee
        SET Salary = Salary * 1.20
        WHERE SSN = @SSN;
    END

    FETCH NEXT FROM Salary_Cursor INTO @SSN, @Salary;
END

CLOSE Salary_Cursor;
DEALLOCATE Salary_Cursor;

--2

DECLARE @DeptName NVARCHAR(100),
        @ManagerName NVARCHAR(100);

DECLARE Dept_Manager_Cursor CURSOR FOR
SELECT 
    d.Dept_Name,
    i.Ins_Name
FROM Department d
JOIN Instructor i
    ON d.dept_manager = i.Ins_Id;

OPEN Dept_Manager_Cursor;

FETCH NEXT FROM Dept_Manager_Cursor INTO @DeptName, @ManagerName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Department: ' + @DeptName + ' | Manager: ' + @ManagerName;

    FETCH NEXT FROM Dept_Manager_Cursor INTO @DeptName, @ManagerName;
END

CLOSE Dept_Manager_Cursor;
DEALLOCATE Dept_Manager_Cursor;


--3
DECLARE @FirstName NVARCHAR(100);
DECLARE @AllNames NVARCHAR(MAX) = '';

-- تعريف الكيرسور
DECLARE StudentNames_Cursor CURSOR FOR
SELECT st_fname
FROM Student;

OPEN StudentNames_Cursor;

FETCH NEXT FROM StudentNames_Cursor INTO @FirstName;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF LEN(@AllNames) > 0
        SET @AllNames = @AllNames + ', ';

    SET @AllNames = @AllNames + ISNULL(@FirstName, '');

    FETCH NEXT FROM StudentNames_Cursor INTO @FirstName;
END

CLOSE StudentNames_Cursor;
DEALLOCATE StudentNames_Cursor;

SELECT @AllNames AS AllStudentNames;

--4
--backup

--5
CREATE LOGIN Ahmed
WITH PASSWORD = 'Str123';  

USE ITI;
GO

CREATE USER Ahmed FOR LOGIN Ahmed;

GRANT SELECT, UPDATE ON Department TO Ahmed;
GRANT SELECT, UPDATE ON Course TO Ahmed;

--7
-- 1️⃣ إنشاء الجدول Work بدون Primary Key
CREATE TABLE Work (
    EmpID INT,
    ProjectID INT,
    Hours INT
);

-- 2️⃣ إدخال بيانات فيها تكرار
INSERT INTO Work (EmpID, ProjectID, Hours) VALUES
(1, 101, 5),
(1, 101, 3),
(1, 102, 4),
(2, 101, 6),
(2, 103, 2),
(2, 103, 5),
(3, 101, 7);

-- 3️⃣ جمع الساعات حسب EmpID فقط مع Subtotal
SELECT 
    EmpID,
    SUM(Hours) AS TotalHours
FROM Work
GROUP BY ROLLUP(EmpID);

-- 4️⃣ جمع الساعات حسب EmpID, ProjectID مع Subtotal
SELECT 
    EmpID,
    ProjectID,
    SUM(Hours) AS TotalHours
FROM Work
GROUP BY ROLLUP(EmpID, ProjectID);

