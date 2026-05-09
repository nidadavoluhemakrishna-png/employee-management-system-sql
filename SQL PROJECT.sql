create  database EMS;

use EMS;

CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT
    );

CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2)
    );
    
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE
    );

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT
    );
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2)
);

alter table employee
add CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE;
        
alter table salarybonus
add CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE;
	
alter table qualification
add CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE;
alter table leaves
add CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE;
alter table payroll
add CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
add CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
add CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
add CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE;
        
select * from employee;


-- EMPLOYEE INSIGHTS

-- 1.How many unique employees are currently in the system?
SELECT COUNT(DISTINCT emp_ID) AS unique_employees
FROM Employee;

-- 2.Which departments have the highest number of employees?
SELECT jd.jobdept, COUNT(e.emp_ID) AS employee_count
FROM JobDepartment jd
JOIN Employee e ON jd.Job_ID = e.Job_ID
GROUP BY jd.jobdept
ORDER BY employee_count DESC;

-- 3.What is the average salary per department?
SELECT jd.jobdept, AVG(sb.amount) AS avg_salary
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY avg_salary DESC;

-- 4.Who are the top 5 highest-paid employees?
SELECT e.emp_ID, e.firstname, e.lastname, sb.amount AS salary
FROM Employee e
JOIN SalaryBonus sb ON e.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 5;

-- 5.What is the total salary expenditure across the company?
SELECT SUM(amount) AS total_salary_expenditure
FROM SalaryBonus;

-- JOB ROLE AND DEPARTMENT ANALYSIS

-- 1.How many different job roles exist in each department?
SELECT jd.jobdept, COUNT(DISTINCT jd.name) AS job_roles_count
FROM JobDepartment jd
GROUP BY jd.jobdept
ORDER BY job_roles_count DESC;

-- 2.What is the average salary range per department?


-- 3.Which job roles offer the highest salary?
SELECT jd.name AS job_role, jd.jobdept, sb.amount AS salary
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 5;

-- 4.Which departments have the highest total salary allocation?
SELECT jd.jobdept, SUM(sb.amount + sb.bonus + sb.annual) AS total_salary_allocation
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY total_salary_allocation DESC;

-- QUALIFICATION AND SKILLS ANALYSIS

-- 1.How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT eq.emp_ID) AS qualified_employee_count
FROM Qualification eq;

-- 2.Which positions require the most qualifications?
SELECT jd.name AS job_role, jd.jobdept, COUNT(jq.qualid) AS qualification_count
FROM JobDepartment jd
JOIN Qualification jq ON jd.job_ID = jq.emp_ID
GROUP BY jd.name, jd.jobdept
ORDER BY qualification_count DESC
LIMIT 5;

-- 3.Which employees have the highest number of qualifications?
SELECT e.emp_ID, e.firstname, e.lastname, COUNT(eq.qualID) AS qualification_count
FROM Employee e
JOIN Qualification eq ON e.emp_ID = eq.emp_ID
GROUP BY e.emp_ID, e.firstname, e.lastname
ORDER BY qualification_count DESC
LIMIT 5;

--  LEAVE AND ABSENCE PATTERNS

-- 1.Which year had the most employees taking leaves?
SELECT YEAR(date) AS leave_year, COUNT(DISTINCT emp_ID) AS employee_count
FROM Leaves
GROUP BY leave_year
ORDER BY employee_count DESC
limit 1;

-- 2.What is the average number of leave days taken by its employees per department?
SELECT jd.jobdept,COUNT(l.leave_ID) * 1.0 / COUNT(DISTINCT e.emp_ID) AS avg_leave_days_per_employee
FROM Leaves l
JOIN Employee e ON l.emp_ID = e.emp_ID
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
GROUP BY jd.jobdept;

-- 3.Which employees have taken the most leaves?
SELECT e.firstname,e.lastname, COUNT(*) AS total_leaves
FROM Leaves l
JOIN Employee e ON l.emp_ID = e.emp_ID
GROUP BY e.firstname,e.lastname
ORDER BY total_leaves DESC
LIMIT 5;

-- 4.What is the total number of leave days taken company-wide?
SELECT COUNT(*) AS total_leave_days
FROM Leaves;

-- 5.How do leave days correlate with payroll amounts?
SELECT l.emp_ID,
       COUNT(l.leave_ID) AS leave_days,
       SUM(p.total_amount) AS total_payroll
FROM Leaves l
JOIN Payroll p ON l.leave_ID = p.leave_ID
GROUP BY l.emp_ID;

--  PAYROLL AND COMPENSATION ANALYSIS

-- 1.What is the total monthly payroll processed?
SELECT DATE_FORMAT(date, '%Y-%m') AS payroll_month, SUM(total_amount) AS total_monthly_payroll
FROM Payroll
GROUP BY payroll_month
ORDER BY payroll_month;

-- 2.What is the average bonus given per department?
SELECT jd.jobdept, AVG(sb.bonus) AS avg_bonus
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.Job_ID = jd.Job_ID
GROUP BY jd.jobdept;


-- 3.Which department receives the highest total bonuses?
SELECT jd.jobdept, SUM(sb.bonus) AS total_bonus
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.Job_ID = jd.Job_ID
GROUP BY jd.jobdept
ORDER BY total_bonus DESC
LIMIT 1;


-- 4.What is the average value of total_amount after considering leave deductions?
SELECT p.emp_ID, COUNT(l.leave_ID) AS leave_days, AVG(p.total_amount) AS avg_payroll
FROM Payroll p
LEFT JOIN Leaves l ON p.leave_ID = l.leave_ID
GROUP BY p.emp_ID;


drop database EMS;