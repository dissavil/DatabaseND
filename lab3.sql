--PART A
CREATE TABLE employees (
    emp_id     SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name  VARCHAR(50),
    department VARCHAR(50), 
    salary     INTEGER     DEFAULT 30000,
    hire_date  DATE,
    status     VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id    SERIAL PRIMARY KEY,
    dept_name  VARCHAR(50),
    budget     INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id   SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id      INTEGER,
    start_date   DATE,
    end_date     DATE,
    budget       INTEGER
);

-- PART B

INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (1, 'Aigerim', 'Sadykova', 'IT'),
       (2, 'Nurlan',  'Bekov',    'Sales'),
       (3, 'Dana',    'Ospanova', 'HR');

SELECT setval(pg_get_serial_sequence('employees', 'emp_id'),
              (SELECT MAX(emp_id) FROM employees));

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Timur', 'Akhmetov', 'IT', DEFAULT, '2019-05-10', DEFAULT);

INSERT INTO departments (dept_name, budget, manager_id)
VALUES ('IT',    150000, 1),
       ('Sales',  90000, 2),
       ('HR',     70000, 3);

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Alina', 'Karimova', 'IT', 50000 * 1.1, CURRENT_DATE);

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Marat',     'Iskakov',     'IT',      85000, '2018-03-15', 'Active'),
       ('Saule',     'Nurpeisova',  'Sales',   65000, '2017-07-01', 'Active'),
       ('Erlan',     'Zhaksybekov', 'HR',      45000, '2021-09-12', 'Inactive'),
       ('Aruzhan',   'Kenzhebek',   'Sales',   38000, '2023-06-01', 'Active'),
       ('Bauyrzhan', 'Omarov',      'Finance', 72000, '2021-01-20', 'Terminated'),
       ('Zhanna',    'Tulegenova',  NULL,      35000, '2023-08-15', 'Active');

INSERT INTO departments (dept_name, budget, manager_id)
VALUES ('Legal', 40000, NULL);

INSERT INTO projects (project_name, dept_id, start_date, end_date, budget)
VALUES ('Website Redesign', 1, '2022-01-01', '2022-12-31', 80000),
       ('CRM Migration',    2, '2023-03-01', '2024-03-01', 60000),
       ('Old Audit',        3, '2020-01-01', '2022-06-30', 20000),
       ('HR Portal',        3, '2024-01-01', '2025-01-01', 30000);

CREATE TEMP TABLE temp_employees (LIKE employees);

INSERT INTO temp_employees
SELECT * FROM employees WHERE department = 'IT';

SELECT * FROM temp_employees;

-- PART C

UPDATE employees
SET salary = salary * 1.10;

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';
BEGIN;

UPDATE employees
SET department = CASE
                     WHEN salary > 80000              THEN 'Management'
                     WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
                     ELSE 'Junior'
                 END;

SELECT emp_id, first_name, salary, department FROM employees ORDER BY emp_id;

ROLLBACK;

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE departments d
SET budget = (SELECT ROUND(AVG(e.salary) * 1.2)
              FROM employees e
              WHERE e.department = d.dept_name)
WHERE EXISTS (SELECT 1
              FROM employees e
              WHERE e.department = d.dept_name
                AND e.salary IS NOT NULL);

SELECT * FROM departments ORDER BY dept_id;

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

-- PART D

DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

DELETE FROM departments
WHERE dept_name NOT IN (SELECT DISTINCT department
                        FROM employees
                        WHERE department IS NOT NULL);

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

-- PART E

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Ghost', 'Employee', NULL, NULL, '2022-02-02');

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;

-- PART F

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Kairat', 'Sarsenov', 'Finance', 48000, '2024-05-20')
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

UPDATE employees AS e
SET salary = e.salary + 5000
FROM (SELECT emp_id, salary
      FROM employees
      WHERE department = 'IT') AS old
WHERE e.emp_id = old.emp_id
RETURNING e.emp_id, old.salary AS old_salary, e.salary AS new_salary;

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

-- PART G

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'Aigerim', 'Sadykova', 'IT', 60000, CURRENT_DATE
WHERE NOT EXISTS (SELECT 1
                  FROM employees
                  WHERE first_name = 'Aigerim'
                    AND last_name  = 'Sadykova');

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'Asel', 'Dauletova', 'HR', 52000, CURRENT_DATE
WHERE NOT EXISTS (SELECT 1
                  FROM employees
                  WHERE first_name = 'Asel'
                    AND last_name  = 'Dauletova');

UPDATE departments SET budget = 150000 WHERE dept_name = 'IT';

UPDATE employees e
SET salary = e.salary * CASE
                            WHEN (SELECT d.budget
                                  FROM departments d
                                  WHERE d.dept_name = e.department) > 100000
                                THEN 1.10
                            ELSE 1.05
                        END
WHERE e.department IN (SELECT dept_name FROM departments);

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Bulat',   'Alimov',   'IT', 40000, '2024-03-01'),
       ('Madina',  'Serikova', 'IT', 45000, '2024-03-01'),
       ('Ruslan',  'Tokaev',   'IT', 50000, '2024-03-01'),
       ('Gulnara', 'Abenova',  'IT', 55000, '2024-03-01'),
       ('Daulet',  'Kasymov',  'IT', 60000, '2024-03-01');

UPDATE employees
SET salary = salary * 1.10
WHERE hire_date = '2024-03-01';

CREATE TABLE employee_archive (LIKE employees);

BEGIN;

INSERT INTO employee_archive
SELECT * FROM employees WHERE status = 'Inactive';

DELETE FROM employees WHERE status = 'Inactive';

COMMIT;

SELECT * FROM employee_archive;

INSERT INTO projects (project_name, dept_id, start_date, end_date, budget)
VALUES ('Cloud Migration', 1, '2024-01-01', '2024-12-31', 80000),
       ('Small IT Tool',   1, '2024-02-01', '2024-06-30', 20000),
       ('HR Analytics',    3, '2024-01-01', '2024-09-30', 60000);

UPDATE projects p
SET end_date = p.end_date + 30
WHERE p.budget > 50000
  AND (SELECT COUNT(*)
       FROM employees e
       WHERE e.department = (SELECT d.dept_name
                             FROM departments d
                             WHERE d.dept_id = p.dept_id)) > 3;

SELECT * FROM projects ORDER BY project_id;