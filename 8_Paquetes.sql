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

CREATE TABLE employees (
    employee_id NUMBER(6) NOT NULL,
    first_name VARCHAR2(20),
    last_name VARCHAR2(20) NOT NULL,
    email VARCHAR2(25) NOT NULL,
    phone_number VARCHAR2(20),
    hire_date DATE NOT NULL,
    job_id VARCHAR2(10) NOT NULL,
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

CREATE TABLE regions (
    region_id NUMBER NOT NULL,
    region_name VARCHAR2(25)
) TABLESPACE mi_tb_tarea;

-- Llave primaria para la tabla REGIONS
ALTER TABLE regions
ADD CONSTRAINT reg_id_pk PRIMARY KEY (region_id);

-- Llave primaria para la tabla COUNTRIES
ALTER TABLE countries
ADD CONSTRAINT country_id_pk PRIMARY KEY (country_id);

-- Llave primaria para la tabla LOCATIONS
ALTER TABLE locations
ADD CONSTRAINT loc_id_pk PRIMARY KEY (location_id);

-- Llave primaria para la tabla DEPARTMENTS
ALTER TABLE departments
ADD CONSTRAINT dept_id_pk PRIMARY KEY (department_id);

-- Llave primaria para la tabla JOBS
ALTER TABLE jobs
ADD CONSTRAINT job_id_pk PRIMARY KEY (job_id);

-- Llave primaria para la tabla EMPLOYEES
ALTER TABLE employees
ADD CONSTRAINT emp_id_pk PRIMARY KEY (employee_id);

-- Llave primaria compuesta para la tabla JOB_HISTORY
ALTER TABLE job_history
ADD CONSTRAINT jhist_emp_id_st_date_pk PRIMARY KEY (employee_id, start_date);

-- Llave foránea en COUNTRIES que referencia a REGIONS
ALTER TABLE countries
ADD CONSTRAINT countr_reg_fk FOREIGN KEY (region_id)
REFERENCES regions(region_id);

-- Llave foránea en LOCATIONS que referencia a COUNTRIES
ALTER TABLE locations
ADD CONSTRAINT loc_c_id_fk FOREIGN KEY (country_id)
REFERENCES countries(country_id);

-- Llave foránea en DEPARTMENTS que referencia a LOCATIONS
ALTER TABLE departments
ADD CONSTRAINT dept_loc_fk FOREIGN KEY (location_id)
REFERENCES locations(location_id);

-- Llave foránea en EMPLOYEES que referencia a JOBS
ALTER TABLE employees
ADD CONSTRAINT emp_job_fk FOREIGN KEY (job_id)
REFERENCES jobs(job_id);

-- Llave foránea en EMPLOYEES que referencia a DEPARTMENTS
ALTER TABLE employees
ADD CONSTRAINT emp_dept_fk FOREIGN KEY (department_id)
REFERENCES departments(department_id);

-- Llave foránea en EMPLOYEES que se referencia a sí misma (jefe/manager)
ALTER TABLE employees
ADD CONSTRAINT emp_manager_fk FOREIGN KEY (manager_id)
REFERENCES employees(employee_id);

-- Llave foránea en DEPARTMENTS que referencia a EMPLOYEES (jefe de departamento)
ALTER TABLE departments
ADD CONSTRAINT dept_mgr_fk FOREIGN KEY (manager_id)
REFERENCES employees(employee_id);

-- Llaves foráneas en JOB_HISTORY
ALTER TABLE job_history
ADD CONSTRAINT jhist_job_fk FOREIGN KEY (job_id)
REFERENCES jobs(job_id);

ALTER TABLE job_history
ADD CONSTRAINT jhist_emp_fk FOREIGN KEY (employee_id)
REFERENCES employees(employee_id);

ALTER TABLE job_history
ADD CONSTRAINT jhist_dept_fk FOREIGN KEY (department_id)
REFERENCES departments(department_id);

-- CREACION DE HORARIOS =====================
-- Tabla para definir los turnos y horarios estándar
CREATE TABLE Horario (
    dia_semana VARCHAR2(20) NOT NULL,
    turno VARCHAR2(10) NOT NULL,
    hora_inicio VARCHAR2(5) NOT NULL, -- Formato HH24:MI
    hora_termino VARCHAR2(5) NOT NULL, -- Formato HH24:MI
    CONSTRAINT pk_horario PRIMARY KEY (dia_semana, turno)
);

-- Tabla para asignar un horario a un empleado
CREATE TABLE Empleado_Horario (
    dia_semana VARCHAR2(20) NOT NULL,
    turno VARCHAR2(10) NOT NULL,
    employee_id NUMBER(6) NOT NULL,
    CONSTRAINT pk_empleado_horario PRIMARY KEY (employee_id, dia_semana),
    CONSTRAINT fk_emphor_horario FOREIGN KEY (dia_semana, turno) REFERENCES Horario(dia_semana, turno),
    CONSTRAINT fk_emphor_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Tabla para registrar la asistencia real (marcaciones)
CREATE TABLE Asistencia_Empleado (
    asistencia_id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY, -- Llave primaria simple
    employee_id NUMBER(6) NOT NULL,
    fecha_real DATE NOT NULL,
    hora_inicio_real TIMESTAMP,
    hora_termino_real TIMESTAMP,
    CONSTRAINT pk_asistencia_empleado PRIMARY KEY (asistencia_id),
    CONSTRAINT fk_asistencia_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT uq_asistencia_empleado UNIQUE (employee_id, fecha_real) -- Un empleado solo puede tener un registro por día
);


-- TERCERA PARTE ======================================

-- Tabla para registrar las capacitaciones ofrecidas
CREATE TABLE Capacitacion (
    capacitacion_id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    nombre_capacitacion VARCHAR2(100) NOT NULL,
    horas_capacitacion NUMBER(3) NOT NULL,
    descripcion VARCHAR2(500),
    CONSTRAINT pk_capacitacion PRIMARY KEY (capacitacion_id)
);

-- Tabla para asignar empleados a las capacitaciones
CREATE TABLE Empleado_Capacitacion (
    employee_id NUMBER(6) NOT NULL,
    capacitacion_id NUMBER NOT NULL,
    CONSTRAINT pk_empleado_capacitacion PRIMARY KEY (employee_id, capacitacion_id),
    CONSTRAINT fk_empcap_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT fk_empcap_capacitacion FOREIGN KEY (capacitacion_id) REFERENCES Capacitacion(capacitacion_id)
);

-- TAREA  =============================
CREATE OR REPLACE PACKAGE employee_pkg AS

    -- PROCEDIMIENTOS CRUD (ya existentes)
    PROCEDURE create_employee (
        p_employee_id   IN employees.employee_id%TYPE,
        p_first_name    IN employees.first_name%TYPE,
        p_last_name     IN employees.last_name%TYPE,
        p_email         IN employees.email%TYPE,
        p_phone_number  IN employees.phone_number%TYPE,
        p_hire_date     IN employees.hire_date%TYPE,
        p_job_id        IN employees.job_id%TYPE,
        p_salary        IN employees.salary%TYPE,
        p_comission_pct IN employees.comission_pct%TYPE,
        p_manager_id    IN employees.manager_id%TYPE,
        p_department_id IN employees.department_id%TYPE
    );
    FUNCTION read_employee (p_employee_id IN employees.employee_id%TYPE) RETURN employees%ROWTYPE;
    PROCEDURE read_employee_csr (p_employee_id IN employees.employee_id%TYPE, p_cursor OUT SYS_REFCURSOR);
    PROCEDURE update_employee (
        p_employee_id   IN employees.employee_id%TYPE,
        p_first_name    IN employees.first_name%TYPE,
        p_last_name     IN employees.last_name%TYPE,
        p_email         IN employees.email%TYPE,
        p_phone_number  IN employees.phone_number%TYPE,
        p_hire_date     IN employees.hire_date%TYPE,
        p_job_id        IN employees.job_id%TYPE,
        p_salary        IN employees.salary%TYPE,
        p_comission_pct IN employees.comission_pct%TYPE,
        p_manager_id    IN employees.manager_id%TYPE,
        p_department_id IN employees.department_id%TYPE
    );
    PROCEDURE delete_employee (p_employee_id IN employees.employee_id%TYPE);
    PROCEDURE show_top_job_rotators;



    -- Muestra promedio de contrataciones por mes y retorna el total de meses.
    FUNCTION get_hiring_stats RETURN NUMBER;

    -- 3.1.3: Muestra estadísticas de salarios y empleados por región.
    PROCEDURE show_regional_stats;

    -- 3.1.4: Muestra el cálculo de vacaciones por empleado y retorna el costo total.
    FUNCTION calculate_vacation_cost RETURN NUMBER;
    
    -- 3.1.5: Calcula las horas laboradas de un empleado en un mes/año.
    FUNCTION calculate_worked_hours (
        p_employee_id IN employees.employee_id%TYPE,
        p_month       IN NUMBER,
        p_year        IN NUMBER
    ) RETURN NUMBER;

    -- 3.1.6: Calcula las horas que faltó un empleado en un mes/año.
    FUNCTION calculate_missed_hours (
        p_employee_id IN employees.employee_id%TYPE,
        p_month       IN NUMBER,
        p_year        IN NUMBER
    ) RETURN NUMBER;

    -- 3.1.7: Genera el reporte de nómina para un mes/año.
    PROCEDURE generate_payroll_report (
        p_month IN NUMBER,
        p_year  IN NUMBER
    );
    
    -- TERCERA PARTE =====================
    --  3.1.1: Calcula el total de horas de capacitación de un empleado.
    FUNCTION get_employee_total_training_hours (
        p_employee_id IN employees.employee_id%TYPE
    ) RETURN NUMBER;

    --  3.1.2: Genera un reporte de participación en capacitaciones.
    PROCEDURE report_training_participation;

END employee_pkg;
/

CREATE OR REPLACE PACKAGE BODY employee_pkg AS

    -- IMPLEMENTACIÓN DE CREATE
    PROCEDURE create_employee (
        p_employee_id   IN employees.employee_id%TYPE,
        p_first_name    IN employees.first_name%TYPE,
        p_last_name     IN employees.last_name%TYPE,
        p_email         IN employees.email%TYPE,
        p_phone_number  IN employees.phone_number%TYPE,
        p_hire_date     IN employees.hire_date%TYPE,
        p_job_id        IN employees.job_id%TYPE,
        p_salary        IN employees.salary%TYPE,
        p_comission_pct IN employees.comission_pct%TYPE,
        p_manager_id    IN employees.manager_id%TYPE,
        p_department_id IN employees.department_id%TYPE
    ) AS
    BEGIN
        INSERT INTO employees (
            employee_id, first_name, last_name, email, phone_number,
            hire_date, job_id, salary, comission_pct, manager_id, department_id
        ) VALUES (
            p_employee_id, p_first_name, p_last_name, p_email, p_phone_number,
            p_hire_date, p_job_id, p_salary, p_comission_pct, p_manager_id, p_department_id
        );
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Empleado ' || p_employee_id || ' creado exitosamente.');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Error: El ID de empleado ' || p_employee_id || ' ya existe.');
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error inesperado al crear empleado: ' || SQLERRM);
            ROLLBACK;
    END create_employee;

    -- IMPLEMENTACIÓN DE READ (Función)
    FUNCTION read_employee (
        p_employee_id IN employees.employee_id%TYPE
    ) RETURN employees%ROWTYPE AS
        v_employee_rec employees%ROWTYPE;
    BEGIN
        SELECT *
        INTO v_employee_rec
        FROM employees
        WHERE employee_id = p_employee_id;
        
        RETURN v_employee_rec;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: No se encontró el empleado con ID ' || p_employee_id);
            RETURN NULL;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error inesperado al leer empleado: ' || SQLERRM);
            RETURN NULL;
    END read_employee;
    
    -- IMPLEMENTACIÓN DE READ (Procedimiento con Cursor)
    PROCEDURE read_employee_csr (
        p_employee_id IN employees.employee_id%TYPE,
        p_cursor      OUT SYS_REFCURSOR
    ) AS
    BEGIN
        OPEN p_cursor FOR
            SELECT * FROM employees
            WHERE employee_id = p_employee_id;
    END read_employee_csr;

    -- IMPLEMENTACIÓN DE UPDATE
    PROCEDURE update_employee (
        p_employee_id   IN employees.employee_id%TYPE,
        p_first_name    IN employees.first_name%TYPE,
        p_last_name     IN employees.last_name%TYPE,
        p_email         IN employees.email%TYPE,
        p_phone_number  IN employees.phone_number%TYPE,
        p_hire_date     IN employees.hire_date%TYPE,
        p_job_id        IN employees.job_id%TYPE,
        p_salary        IN employees.salary%TYPE,
        p_comission_pct IN employees.comission_pct%TYPE,
        p_manager_id    IN employees.manager_id%TYPE,
        p_department_id IN employees.department_id%TYPE
    ) AS
    BEGIN
        UPDATE employees
        SET
            first_name = p_first_name,
            last_name = p_last_name,
            email = p_email,
            phone_number = p_phone_number,
            hire_date = p_hire_date,
            job_id = p_job_id,
            salary = p_salary,
            comission_pct = p_comission_pct,
            manager_id = p_manager_id,
            department_id = p_department_id
        WHERE employee_id = p_employee_id;
        
        IF SQL%NOTFOUND THEN
            DBMS_OUTPUT.PUT_LINE('Aviso: No se encontró el empleado con ID ' || p_employee_id || '. No se actualizó nada.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Empleado ' || p_employee_id || ' actualizado exitosamente.');
            COMMIT;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error inesperado al actualizar empleado: ' || SQLERRM);
            ROLLBACK;
    END update_employee;

    -- IMPLEMENTACIÓN DE DELETE
    PROCEDURE delete_employee (
        p_employee_id IN employees.employee_id%TYPE
    ) AS
    BEGIN
        DELETE FROM employees
        WHERE employee_id = p_employee_id;
        
        IF SQL%NOTFOUND THEN
            DBMS_OUTPUT.PUT_LINE('Aviso: No se encontró el empleado con ID ' || p_employee_id || '. No se eliminó nada.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Empleado ' || p_employee_id || ' eliminado exitosamente.');
            COMMIT;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error inesperado al eliminar empleado: ' || SQLERRM);
            ROLLBACK;
    END delete_employee;

    -- IMPLEMENTACIÓN DEL PROCEDIMIENTO ESPECIAL 3.1.1
    PROCEDURE show_top_job_rotators AS
        -- Se define un cursor para obtener la información requerida.
        CURSOR c_top_rotators IS
            -- 1. Se calcula el número de cambios de puesto para cada empleado desde la tabla job_history
            WITH job_changes AS (
                SELECT
                    employee_id,
                    COUNT(*) AS num_changes
                FROM job_history
                GROUP BY employee_id
            )
            -- 2. Se une el resultado con employees y jobs para obtener los datos completos
            SELECT
                e.employee_id,
                e.last_name,
                e.first_name,
                e.job_id AS current_job_id,
                j.job_title AS current_job_title,
                jc.num_changes
            FROM employees e
            JOIN jobs j ON e.job_id = j.job_id
            JOIN job_changes jc ON e.employee_id = jc.employee_id
            -- 3. Se ordena por el número de cambios de forma descendente
            ORDER BY jc.num_changes DESC
            -- 4. Se limita el resultado a las primeras 4 filas
            FETCH FIRST 4 ROWS ONLY;

    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- EMPLEADOS CON MAYOR ROTACIÓN DE PUESTO ---');
        DBMS_OUTPUT.PUT_LINE(RPAD('ID', 8) || RPAD('APELLIDO', 20) || RPAD('NOMBRE', 20) || RPAD('PUESTO ACTUAL', 30) || 'CAMBIOS');
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 7, '-') || ' ' || RPAD('-', 19, '-') || ' ' || RPAD('-', 19, '-') || ' ' || RPAD('-', 29, '-') || ' ' || RPAD('-', 7, '-'));

        -- Se recorre el cursor y se imprime cada registro
        FOR rec IN c_top_rotators LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(rec.employee_id, 8) ||
                RPAD(rec.last_name, 20) ||
                RPAD(rec.first_name, 20) ||
                RPAD(rec.current_job_title, 30) ||
                rec.num_changes
            );
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error inesperado al obtener el reporte: ' || SQLERRM);
    END show_top_job_rotators;
    
    -- IMPLEMENTACIÓN DE 3.1.2: FUNCIÓN DE ESTADÍSTICAS DE CONTRATACIÓN
    FUNCTION get_hiring_stats RETURN NUMBER AS
        v_total_months NUMBER := 0;
        
        CURSOR c_hiring_avg IS
            -- Paso 1: Contar las contrataciones por cada mes de cada año específico.
            WITH hires_per_month_year AS (
                SELECT
                    TO_CHAR(hire_date, 'MM') AS month_number,
                    COUNT(employee_id) AS num_hires
                FROM employees
                GROUP BY TO_CHAR(hire_date, 'YYYY'), TO_CHAR(hire_date, 'MM')
            )
            -- Paso 2: Calcular el promedio de esas contrataciones para cada mes a través de los años.
            SELECT
                TO_CHAR(TO_DATE(month_number, 'MM'), 'Month', 'NLS_DATE_LANGUAGE=SPANISH') AS month_name,
                ROUND(AVG(num_hires), 2) AS average_hires
            FROM hires_per_month_year
            GROUP BY month_number
            ORDER BY TO_NUMBER(month_number);
            
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- PROMEDIO DE CONTRATACIONES MENSUALES (HISTÓRICO) ---');
        DBMS_OUTPUT.PUT_LINE(RPAD('MES', 20) || 'PROMEDIO DE CONTRATACIONES');
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 19, '-') || ' ' || RPAD('-', 28, '-'));

        FOR rec IN c_hiring_avg LOOP
            DBMS_OUTPUT.PUT_LINE(RPAD(INITCAP(rec.month_name), 20) || rec.average_hires);
            v_total_months := v_total_months + 1;
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
        RETURN v_total_months;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error inesperado en get_hiring_stats: ' || SQLERRM);
            RETURN 0;
    END get_hiring_stats;

    -- IMPLEMENTACIÓN DE 3.1.3: PROCEDIMIENTO DE ESTADÍSTICAS REGIONALES
    PROCEDURE show_regional_stats AS
        CURSOR c_regional_stats IS
            SELECT
                r.region_name,
                SUM(e.salary) AS total_salary,
                COUNT(e.employee_id) AS total_employees,
                MIN(e.hire_date) AS oldest_hire_date
            FROM regions r
            JOIN countries c ON r.region_id = c.region_id
            JOIN locations l ON c.country_id = l.country_id
            JOIN departments d ON l.location_id = d.location_id
            JOIN employees e ON d.department_id = e.department_id
            GROUP BY r.region_name
            ORDER BY r.region_name;
            
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- ESTADÍSTICAS DE GASTOS Y EMPLEADOS POR REGIÓN ---');
        DBMS_OUTPUT.PUT_LINE(
            RPAD('REGIÓN', 25) || 
            RPAD('SUMA SALARIOS', 18) || 
            RPAD('CANT. EMPLEADOS', 20) || 
            'INGRESO MÁS ANTIGUO'
        );
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 120, '-'));

        FOR rec IN c_regional_stats LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(rec.region_name, 25) || 
                RPAD(TO_CHAR(rec.total_salary, 'FM999G999G990D00'), 18) || 
                RPAD(rec.total_employees, 20) || 
                TO_CHAR(rec.oldest_hire_date, 'DD/MM/YYYY')
            );
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error inesperado en show_regional_stats: ' || SQLERRM);
    END show_regional_stats;

    -- IMPLEMENTACIÓN DE 3.1.4: FUNCIÓN DE CÁLCULO DE VACACIONES
    FUNCTION calculate_vacation_cost RETURN NUMBER AS
        v_total_vacation_cost NUMBER := 0;
        v_service_years       NUMBER;
        v_vacation_months     NUMBER;
        v_vacation_cost       NUMBER;
        
        CURSOR c_employees IS
            SELECT employee_id, first_name, last_name, hire_date, salary
            FROM employees
            ORDER BY last_name;
            
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- CÁLCULO DE TIEMPO DE SERVICIO Y COSTO DE VACACIONES ---');
        DBMS_OUTPUT.PUT_LINE(
            RPAD('EMPLEADO', 35) || 
            RPAD('AÑOS SERVICIO', 18) || 
            RPAD('MESES VACACIONES', 20) || 
            'COSTO ESTIMADO'
        );
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 120, '-'));

        FOR rec IN c_employees LOOP
            -- Calcula los años de servicio completos
            v_service_years := FLOOR(MONTHS_BETWEEN(SYSDATE, rec.hire_date) / 12);
            
            -- Por cada año, corresponde un mes de vacaciones
            v_vacation_months := v_service_years;
            
            -- El costo es el salario mensual por la cantidad de meses de vacaciones
            v_vacation_cost := rec.salary * v_vacation_months;
            
            DBMS_OUTPUT.PUT_LINE(
                RPAD(rec.first_name || ' ' || rec.last_name, 35) ||
                RPAD(v_service_years, 18) ||
                RPAD(v_vacation_months, 20) ||
                TO_CHAR(v_vacation_cost, 'FM999G999G990D00')
            );
            
            -- Suma al total general
            v_total_vacation_cost := v_total_vacation_cost + v_vacation_cost;
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
        RETURN v_total_vacation_cost;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error inesperado en calculate_vacation_cost: ' || SQLERRM);
            RETURN 0;
    END calculate_vacation_cost;
    
    -- Segunda parte =============================
    -- IMPLEMENTACIÓN DE 3.1.5: FUNCIÓN PARA CALCULAR HORAS LABORADAS
    FUNCTION calculate_worked_hours (
        p_employee_id IN employees.employee_id%TYPE,
        p_month       IN NUMBER,
        p_year        IN NUMBER
    ) RETURN NUMBER AS
        v_total_hours NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(
            (CAST(hora_termino_real AS DATE) - CAST(hora_inicio_real AS DATE)) * 24
        ), 0)
        INTO v_total_hours
        FROM Asistencia_Empleado
        WHERE employee_id = p_employee_id
          AND EXTRACT(YEAR FROM fecha_real) = p_year
          AND EXTRACT(MONTH FROM fecha_real) = p_month;
          
        RETURN v_total_hours;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END calculate_worked_hours;

    -- IMPLEMENTACIÓN DE 3.1.6: FUNCIÓN PARA CALCULAR HORAS FALTANTES
    FUNCTION calculate_missed_hours (
        p_employee_id IN employees.employee_id%TYPE,
        p_month       IN NUMBER,
        p_year        IN NUMBER
    ) RETURN NUMBER AS
        v_scheduled_hours NUMBER := 0;
        v_worked_hours    NUMBER;
        v_missed_hours    NUMBER;
        v_start_date      DATE := TO_DATE('01-' || p_month || '-' || p_year, 'DD-MM-YYYY');
        v_end_date        DATE := LAST_DAY(v_start_date);
        
        -- Cursor para obtener el horario teórico del empleado
        CURSOR c_schedule (p_day_name VARCHAR2) IS
            SELECT 
                (TO_DATE(h.hora_termino, 'HH24:MI') - TO_DATE(h.hora_inicio, 'HH24:MI')) * 24 AS shift_duration
            FROM Empleado_Horario eh
            JOIN Horario h ON eh.dia_semana = h.dia_semana AND eh.turno = h.turno
            WHERE eh.employee_id = p_employee_id
              AND eh.dia_semana = p_day_name;
              
        v_shift_duration NUMBER;
        
    BEGIN
        -- 1. Calcular las horas teóricas (programadas) para el mes
        FOR day_rec IN (SELECT v_start_date + LEVEL - 1 AS current_day
                        FROM DUAL
                        CONNECT BY LEVEL <= (v_end_date - v_start_date) + 1)
        LOOP
            -- Solo se cuentan días de Lunes a Viernes
            IF TO_CHAR(day_rec.current_day, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') NOT IN ('SAT', 'SUN') THEN
                OPEN c_schedule(TRIM(TO_CHAR(day_rec.current_day, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH')));
                FETCH c_schedule INTO v_shift_duration;
                IF c_schedule%FOUND THEN
                    v_scheduled_hours := v_scheduled_hours + v_shift_duration;
                END IF;
                CLOSE c_schedule;
            END IF;
        END LOOP;
        
        -- 2. Obtener las horas realmente trabajadas
        v_worked_hours := calculate_worked_hours(p_employee_id, p_month, p_year);
        
        -- 3. Calcular la diferencia
        v_missed_hours := v_scheduled_hours - v_worked_hours;
        
        -- Retornar 0 si el empleado trabajó de más
        RETURN GREATEST(0, v_missed_hours);
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END calculate_missed_hours;
    
    -- IMPLEMENTACIÓN DE 3.1.7: PROCEDIMIENTO PARA GENERAR NÓMINA
    PROCEDURE generate_payroll_report (
        p_month IN NUMBER,
        p_year  IN NUMBER
    ) AS
        v_worked_hours      NUMBER;
        v_missed_hours      NUMBER;
        v_total_sched_hours NUMBER;
        v_hourly_rate       NUMBER;
        v_final_salary      NUMBER;
        
        -- Cursor para procesar solo empleados con horario asignado
        CURSOR c_employees_with_schedule IS
            SELECT DISTINCT e.employee_id, e.first_name, e.last_name, e.salary
            FROM employees e
            JOIN Empleado_Horario eh ON e.employee_id = eh.employee_id;
            
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- REPORTE DE NÓMINA PARA ' || TO_CHAR(TO_DATE(p_month, 'MM'), 'Month') || ' ' || p_year || ' ---');
        DBMS_OUTPUT.PUT_LINE(RPAD('EMPLEADO', 35) || 'SALARIO CALCULADO');
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 34, '-') || ' ' || RPAD('-', 19, '-'));
        
        FOR emp IN c_employees_with_schedule LOOP
            v_worked_hours := calculate_worked_hours(emp.employee_id, p_month, p_year);
            v_missed_hours := calculate_missed_hours(emp.employee_id, p_month, p_year);
            
            v_total_sched_hours := v_worked_hours + v_missed_hours;
            
            IF v_total_sched_hours > 0 THEN
                -- Se calcula el valor por hora en base al salario mensual y las horas programadas
                v_hourly_rate := emp.salary / v_total_sched_hours;
                v_final_salary := v_hourly_rate * v_worked_hours;
            ELSE
                v_final_salary := 0; -- No tenía horas programadas este mes
            END IF;
            
            DBMS_OUTPUT.PUT_LINE(
                RPAD(emp.first_name || ' ' || emp.last_name, 35) || 
                TO_CHAR(v_final_salary, 'FM999G999G990D00')
            );
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
        
    END generate_payroll_report;
    
    -- IMPLEMENTACIÓN DE 3.1.1: FUNCIÓN PARA OBTENER HORAS TOTALES DE CAPACITACIÓN
    FUNCTION get_employee_total_training_hours (
        p_employee_id IN employees.employee_id%TYPE
    ) RETURN NUMBER AS
        v_total_hours NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(c.horas_capacitacion), 0)
        INTO v_total_hours
        FROM Capacitacion c
        JOIN Empleado_Capacitacion ec ON c.capacitacion_id = ec.capacitacion_id
        WHERE ec.employee_id = p_employee_id;
        
        RETURN v_total_hours;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END get_employee_total_training_hours;

    -- IMPLEMENTACIÓN DE 3.1.2: PROCEDIMIENTO PARA REPORTAR PARTICIPACIÓN EN CAPACITACIONES
    PROCEDURE report_training_participation AS
        CURSOR c_capacitaciones IS
            SELECT capacitacion_id, nombre_capacitacion, horas_capacitacion
            FROM Capacitacion
            ORDER BY horas_capacitacion DESC;
            
        CURSOR c_empleados_por_capacitacion (p_capacitacion_id NUMBER) IS
            SELECT e.first_name, e.last_name, e.employee_id
            FROM employees e
            JOIN Empleado_Capacitacion ec ON e.employee_id = ec.employee_id
            WHERE ec.capacitacion_id = p_capacitacion_id;
            
        v_total_horas_empleado NUMBER;
            
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- REPORTE DE PARTICIPACIÓN EN CAPACITACIONES ---');
        
        FOR cap IN c_capacitaciones LOOP
            DBMS_OUTPUT.PUT_LINE(' ');
            DBMS_OUTPUT.PUT_LINE('Capacitación: ' || cap.nombre_capacitacion || ' (' || cap.horas_capacitacion || ' horas)');
            DBMS_OUTPUT.PUT_LINE(RPAD('-', 80, '-'));
            
            FOR emp IN c_empleados_por_capacitacion(cap.capacitacion_id) LOOP
                v_total_horas_empleado := get_employee_total_training_hours(emp.employee_id);
                DBMS_OUTPUT.PUT_LINE(
                    '  -> ' || RPAD(emp.first_name || ' ' || emp.last_name, 30) ||
                    '(Horas totales acumuladas: ' || v_total_horas_empleado || ')'
                );
            END LOOP;
        END LOOP;
        
    END report_training_participation;

END employee_pkg;
/



BEGIN
    employee_pkg.show_top_job_rotators;
END;
/

DECLARE
    v_meses_contados NUMBER;
BEGIN
    v_meses_contados := employee_pkg.get_hiring_stats;
    DBMS_OUTPUT.PUT_LINE('Total de meses en el listado: ' || v_meses_contados);
END;
/

BEGIN
    employee_pkg.show_regional_stats;
END;
/

DECLARE
    v_costo_total NUMBER;
BEGIN
    v_costo_total := employee_pkg.calculate_vacation_cost;
    DBMS_OUTPUT.PUT_LINE('Monto total empleado para el tiempo de servicios (vacaciones): ' || TO_CHAR(v_costo_total, 'FM$999G999G990D00'));
END;
/

-- 3.1.5
DECLARE
    v_horas NUMBER;
BEGIN
    v_horas := employee_pkg.calculate_worked_hours(p_employee_id => 103, p_month => 10, p_year => 2025);
    DBMS_OUTPUT.PUT_LINE('Horas laboradas por el empleado 103: ' || ROUND(v_horas, 2));
END;
/

-- 3.1.6
DECLARE
    v_horas_faltantes NUMBER;
BEGIN
    v_horas_faltantes := employee_pkg.calculate_missed_hours(p_employee_id => 176, p_month => 10, p_year => 2025);
    DBMS_OUTPUT.PUT_LINE('Horas faltantes del empleado 176: ' || ROUND(v_horas_faltantes, 2));
END;
/

-- 3.1.7
BEGIN
    employee_pkg.generate_payroll_report(p_month => 10, p_year => 2025);
END;
/
-- TERCERA PARTE ==========
-- Probar la función (3.1.1) para el empleado 103
DECLARE
    v_horas NUMBER;
BEGIN
    v_horas := employee_pkg.get_employee_total_training_hours(103);
    DBMS_OUTPUT.PUT_LINE('Horas totales de capacitación para el empleado 103: ' || v_horas);
END;
/

-- Probar el procedimiento de reporte (3.1.2)
BEGIN
    employee_pkg.report_training_participation;
END;
/

-- CREACION DE TRIGGERS
CREATE OR REPLACE TRIGGER TRG_CHECK_ASISTENCIA
BEFORE INSERT ON Asistencia_Empleado
FOR EACH ROW
DECLARE
    v_count NUMBER;
    v_dia_semana_real VARCHAR2(20);
BEGIN
    -- Obtener el nombre del día de la semana de la fecha de asistencia
    v_dia_semana_real := TRIM(UPPER(TO_CHAR(:NEW.fecha_real, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH')));
    
    -- Verificar si el empleado tiene un horario asignado para ese día de la semana
    SELECT COUNT(*)
    INTO v_count
    FROM Empleado_Horario
    WHERE employee_id = :NEW.employee_id
      AND dia_semana = v_dia_semana_real;
      
    -- Si el conteo es 0, significa que no debía trabajar ese día. Se lanza un error.
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error de Asistencia: El empleado ' || :NEW.employee_id || ' no tiene un turno programado para el día ' || v_dia_semana_real || '.');
    END IF;
END;
/

-- ESTE INSERT DEBE FALLAR
INSERT INTO Asistencia_Empleado (employee_id, fecha_real, hora_inicio_real, hora_termino_real) VALUES (103, TO_DATE('2025-10-25', 'YYYY-MM-DD'), NULL, NULL);

CREATE OR REPLACE TRIGGER TRG_VALIDATE_SALARY
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
DECLARE
    v_min_salary jobs.min_salary%TYPE;
    v_max_salary jobs.max_salary%TYPE;
BEGIN
    -- Obtener el rango salarial para el puesto del empleado
    SELECT min_salary, max_salary
    INTO v_min_salary, v_max_salary
    FROM jobs
    WHERE job_id = :NEW.job_id;
    
    -- Validar si el nuevo salario está fuera del rango
    IF :NEW.salary NOT BETWEEN v_min_salary AND v_max_salary THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error de Salario: El sueldo ' || :NEW.salary || ' está fuera del rango (' || v_min_salary || ' - ' || v_max_salary || ') para el puesto ' || :NEW.job_id || '.');
    END IF;
END;
/

-- ESTE UPDATE DEBE FALLAR (Rango de IT_PROG es 4000-10000)
UPDATE employees SET salary = 20000 WHERE employee_id = 103;

CREATE OR REPLACE TRIGGER TRG_RESTRICT_ACCESS_TIME
BEFORE INSERT ON Asistencia_Empleado
FOR EACH ROW
DECLARE
    v_scheduled_start_str VARCHAR2(5);
    v_scheduled_start_ts  TIMESTAMP;
    v_lower_bound         TIMESTAMP;
    v_upper_bound         TIMESTAMP;
    v_dia_semana_real     VARCHAR2(20);
BEGIN
    -- Solo actuar si se está registrando una hora de inicio
    IF :NEW.hora_inicio_real IS NOT NULL THEN
        
        v_dia_semana_real := TRIM(UPPER(TO_CHAR(:NEW.fecha_real, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH')));
        
        -- 1. Encontrar la hora de inicio programada para ese día
        BEGIN
            SELECT h.hora_inicio
            INTO v_scheduled_start_str
            FROM Horario h
            JOIN Empleado_Horario eh ON h.dia_semana = eh.dia_semana AND h.turno = eh.turno
            WHERE eh.employee_id = :NEW.employee_id
              AND eh.dia_semana = v_dia_semana_real;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Si no tiene horario, no hacemos nada con este trigger
                RETURN;
        END;

        -- 2. Construir la ventana de tiempo permitida (+/- 30 minutos)
        -- Convertimos la hora programada (texto) a un TIMESTAMP completo del día de hoy
        v_scheduled_start_ts := TO_TIMESTAMP(TO_CHAR(:NEW.fecha_real, 'YYYY-MM-DD') || ' ' || v_scheduled_start_str, 'YYYY-MM-DD HH24:MI');
        
        -- Calculamos los límites
        v_lower_bound := v_scheduled_start_ts - INTERVAL '30' MINUTE;
        v_upper_bound := v_scheduled_start_ts + INTERVAL '30' MINUTE;
        
        -- 3. Verificar si la marcación está fuera de la ventana
        IF :NEW.hora_inicio_real NOT BETWEEN v_lower_bound AND v_upper_bound THEN
            -- Marcación fuera de tiempo. Se marca como inasistencia silenciosa.
            -- El registro se insertará, pero sin horas de inicio ni fin.
            :NEW.hora_inicio_real := NULL;
            :NEW.hora_termino_real := NULL;
        END IF;
        
    END IF;
END;
/

-- Este INSERT tendrá éxito, pero guardará las horas como NULL
INSERT INTO Asistencia_Empleado (employee_id, fecha_real, hora_inicio_real, hora_termino_real) VALUES (103, TO_DATE('2025-10-27', 'YYYY-MM-DD'), TO_TIMESTAMP('2025-10-27 09:05', 'YYYY-MM-DD HH24:MI'), NULL);

-- Verifica el resultado (verás los campos de hora vacíos para este registro)
SELECT * FROM Asistencia_Empleado WHERE employee_id = 103 AND fecha_real = TO_DATE('2025-10-27', 'YYYY-MM-DD');
