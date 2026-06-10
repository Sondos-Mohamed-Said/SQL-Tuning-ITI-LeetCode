Use ITI 
--1
 --Create a scalar function that takes date and returns Month name of that date. 

create function getmonth(@d date)
returns varchar(50)
as 
begin
DECLARE @month_name varchar(50)

    SET @month_name = DATENAME(MONTH, @d)

    RETURN @month_name
end

print  dbo.getmonth('10-1-2003')

--2
 --Create a multi-statements table-valued function that takes 2 integers and
 --returns the Even values between them. 
 

CREATE FUNCTION get_even_numbers(@num1 INT, @num2 INT)
RETURNS @result TABLE
(
    even_number INT
)
AS
BEGIN
    DECLARE @start INT
    DECLARE @end INT
    DECLARE @i INT

    IF @num1 <= @num2
    BEGIN
        SET @start = @num1
        SET @end = @num2
    END
    ELSE
    BEGIN
        SET @start = @num2
        SET @end = @num1
    END

    SET @i = @start
    WHILE @i <= @end
    BEGIN
        IF @i % 2 = 0
        BEGIN
            INSERT INTO @result VALUES (@i)
        END
        SET @i = @i + 1
    END

    RETURN
END

select * from get_even_numbers(10,2)



 
--3
--Create inline function that takes Student No and returns Department 
--Name with Student full name. 

CREATE FUNCTION get_student_department(@student_no INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        s.st_fname + ' ' + s.st_lname AS full_name,
        d.dept_name
    FROM 
        student s
    JOIN 
        department d ON s.dept_id = d.dept_id
    WHERE 
        s.st_id = @student_no
)

select * from get_student_department(1)


 
--4
--Create a scalar function that takes Student ID and returns a message to user  
CREATE FUNCTION get_name_status(@student_id INT)
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @fname NVARCHAR(50)
    DECLARE @lname NVARCHAR(50)
    DECLARE @msg VARCHAR(100)

    SELECT 
        @fname = st_fname,
        @lname = st_lname
    FROM Student
    WHERE st_id = @student_id

    IF @fname IS NULL AND @lname IS NULL
        SET @msg = 'First name & last name are null'
    ELSE IF @fname IS NULL
        SET @msg = 'First name is null'
    ELSE IF @lname IS NULL
        SET @msg = 'Last name is null'
    ELSE
        SET @msg = 'First name & last name are not null'

    RETURN @msg
END

select dbo.get_name_status(1)

--5
--Create inline function that takes integer which represents manager ID and
--displays department name, Manager Name and hiring date  

CREATE FUNCTION get_manager_info(@mgr_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        D.Dept_Name,
        I.Ins_Name AS Manager_Name,
        D.Manager_hiredate
    FROM 
        Department D
    JOIN 
        Instructor I ON D.Dept_Manager = I.Ins_Id
    WHERE 
        D.Dept_Manager = @mgr_id
)
select * from get_manager_info(20)



--6
--Create multi-statements table-valued function that takes a string 

CREATE FUNCTION get_student_names(@option NVARCHAR(50))
RETURNS @result TABLE
(
    student_name NVARCHAR(100)
)
AS
BEGIN
    IF @option = 'first name'
    BEGIN
        INSERT INTO @result
        SELECT ISNULL(st_fname, 'No First Name')
        FROM Student
    END
    ELSE IF @option = 'last name'
    BEGIN
        INSERT INTO @result
        SELECT ISNULL(st_lname, 'No Last Name')
        FROM Student
    END
    ELSE IF @option = 'full name'
    BEGIN
        INSERT INTO @result
        SELECT ISNULL(st_fname, 'No First Name') + ' ' + ISNULL(st_lname, 'No Last Name')
        FROM Student
    END

    RETURN
END
select * from get_student_names('first name')



