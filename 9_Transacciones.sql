CREATE TABLESPACE mi_tb_tarea
DATAFILE 'C:\app\USER\product\21c\oradata\XE\mi_tb_tarea01.dbf'
SIZE 10M AUTOEXTEND ON NEXT 10M MAXSIZE 500M
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TEMPORARY TABLESPACE mi_tb_tmp_tarea
TEMPFILE 'C:\app\USER\product\21c\oradata\XE\mi_tb_tmp_tarea01.dbf'
SIZE 10M
EXTENT MANAGEMENT LOCAL;

CREATE TABLE countries (
    country_id CHAR(2) NOT NULL,
    country_name VARCHAR2(40),
    region_id NUMBER
) TABLESPACE mi_tb_tarea;

CREATE TABLE departments (
    department_id NUMBER(4) NOT NULL,
    department_name VARCHAR2(30) NOT NULL,
    manager_id NUMBER(6),
    location_id NUMBER(4)
) TABLESPACE mi_tb_tarea;

CREATE TABLE regions (
    region_id NUMBER NOT NULL,
    region_name VARCHAR2(25)
) TABLESPACE mi_tb_tarea;

CREATE TABLE employees (
    employee_id NUMBER(6) NOT NULL,
    first_name VARCHAR2(20),
    last_name VARCHAR2(25) NOT NULL,
    email VARCHAR2(25) NOT NULL,
    phone_number VARCHAR2(20),
    hire_date DATE NOT NULL,
    job_id VARCHAR2(20) NOT NULL,
    salary NUMBER(8,2),
    comission_pct NUMBER(2,2),
    manager_id NUMBER(6),
    department_id NUMBER(4)
) TABLESPACE mi_tb_tarea;

CREATE TABLE jobs (
    job_id VARCHAR2(10) NOT NULL,
    job_title VARCHAR2(35) NOT NULL,
    min_salary NUMBER(6),
    max_salary NUMBER(6)
) TABLESPACE mi_tb_tarea;

CREATE TABLE job_history (
    employee_id NUMBER(6) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    job_id VARCHAR2(10) NOT NULL,
    department_id NUMBER(4)
) TABLESPACE mi_tb_tarea;

CREATE TABLE locations (
    location_id NUMBER(4) NOT NULL,
    street_address VARCHAR2(40),
    postal_code VARCHAR2(12),
    city VARCHAR2(30) NOT NULL,
    state_province VARCHAR2(25),
    country_id CHAR(2)
) TABLESPACE mi_tb_tarea;

-- LLAVES PRIMARIAS
ALTER TABLE countries
ADD CONSTRAINT pk_countries
PRIMARY KEY (country_id);

ALTER TABLE departments
ADD CONSTRAINT pk_departments
PRIMARY KEY (department_id);

ALTER TABLE employees
ADD CONSTRAINT pk_employees
PRIMARY KEY (employee_id);

ALTER TABLE locations
ADD CONSTRAINT pk_locations
PRIMARY KEY (location_id);

ALTER TABLE job_history
ADD CONSTRAINT pk_job_history
PRIMARY KEY (employee_id, start_date);

-- LLAVES FORANEAS
ALTER TABLE countries
ADD CONSTRAINT fk_countries_regions
FOREIGN KEY (region_id) REFERENCES regions(region_id);

ALTER TABLE departments
ADD CONSTRAINT fk_departments_managers
FOREIGN KEY (manager_id)
REFERENCES employees(employee_id);

ALTER TABLE departments
ADD CONSTRAINT fk_departments_locations
FOREIGN KEY (location_id)
REFERENCES locations(location_id);

ALTER TABLE job_history
ADD CONSTRAINT fk_job_history_jobs
FOREIGN KEY (job_id)
REFERENCES jobs(job_id);

ALTER TABLE job_history
ADD CONSTRAINT fk_job_history_departments
FOREIGN KEY (department_id)
REFERENCES departments(department_id);

ALTER TABLE locations
ADD CONSTRAINT fk_locations_countries
FOREIGN KEY (country_id)
REFERENCES countries(country_id);

ALTER TABLE employees
ADD CONSTRAINT fk_employees_jobs
FOREIGN KEY (job_id)
REFERENCES jobs(job_id);

ALTER TABLE employees
ADD CONSTRAINT  fk_employees_manager
FOREIGN KEY (manager_id)
REFERENCES employees(employee_id);

ALTER TABLE employees
ADD CONSTRAINT fk_employees_departments
FOREIGN KEY (department_id)
REFERENCES departments(department_id);

--1=================
DECLARE
BEGIN
    -- AUMENTAR 10% salario empleados departamento 90
    UPDATE employees
    SET salary = salary * 1.10
    WHERE deparment_id = 90;
    
    -- Crear savepoint
    SAVEPOINT punto1;
    
    -- Aumentar 5% salario empleados departamento 60
    UPDATE employees
    SET salary = salary * 1.05
    WHERE department_id = 60;
    
    -- ROLLBACK
    ROLLBACK TO SAVEPOINT punto1;
    
    COMMIT;
END;
/

-- 2
UPDATE employees
SET salary = salary + 600
WHERE employee_id = 103;
ROLLBACK;

SELECT * FROM v$lock WHERE block = 1;


-- 3 
DECLARE
    v_employee_id NUMBER := 101;
    v_new_dept_id NUMBER := 20;
    v_old_dept_id NUMBER;
    v_job_id VARCHAR2(10);
    v_start_date DATE := SYSDATE;
BEGIN
    --Obtener datos actuales del empleado
    SELECT department_id, job_id INTO v_old_dept_id, v_job_id
    FROM employees
    WHERE employee_id = v_employee_id;
    
    -- Actualizar departamento del empleado
    UPDATE employees
    SET department_id = v_new_dept_id
    WHERE employee_id = v_employee_id;
    
    -- Insertar registro en job_history
    INSERT INTO job_history (employee_id, start_date, end_date, job_id, department_id)
    VALUES (v_employee_id, v_start_date, v_start_date, v_job_id, v_old_dept_id);
    
    -- Confirmar cambios
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transferencia realizada correctamente');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error en la transferencia: '|| SQLERRM);
END;
/   

-- 4
DECLARE
BEGIN
    -- Aumentar 8% el salario empleados departamento 100
    UPDATE employees
    SET salary = salary * 1.08
    WHERE department_id = 100;
    
    SAVEPOINT A;
    
    -- Aumentar 5% el salario empleados departamento 80
    UPDATE employees
    SET salary = salary * 1.05
    WHERE department_id = 80;
    
    SAVEPOINT B;
    
    -- Eliminar empleados departamento 50
    DELETE FROM employees
    WHERE department_id = 50;
    
    -- Revertir cambios hasta SAVEPOINT B (revierte DELETE)
    ROLLBACK TO SAVEPOINT B;
    
    COMMIT;
END;
/
