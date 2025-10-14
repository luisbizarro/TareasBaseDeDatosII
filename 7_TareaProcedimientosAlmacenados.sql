CREATE TABLESPACE tb_tarea
DATAFILE 'C:\app\USER\product\21c\oradata\XE\tb_tarea01.dbf'
SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE 500M
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TEMPORARY TABLESPACE tb_temporal_tarea
TEMPFILE 'C:\app\USER\product\21c\oradata\XE\tb_temporal_tarea01.dbf'
SIZE 100M
EXTENT MANAGEMENT LOCAL;

-- Creacion de tablas sin pk y fk

CREATE TABLE proveedores (
    s# VARCHAR2(10),
    sname VARCHAR2(100),
    status NUMBER(8),
    city VARCHAR2(100)
) TABLESPACE tb_tarea;

CREATE TABLE partes (
    p# VARCHAR2(10),
    pname VARCHAR2(100),
    color VARCHAR2(50),
    weight NUMBER(8),
    city VARCHAR2(100)
) TABLESPACE tb_tarea;

CREATE TABLE envios (
    s# VARCHAR2(10),
    p# VARCHAR2(10),
    qty NUMBER(8)
) TABLESPACE tb_tarea;

CREATE TABLE proyectos (
    j# VARCHAR2(10),
    jname VARCHAR2(100),
    city VARCHAR2(100)
) TABLESPACE tb_tarea;

CREATE TABLE enviosproyectos (
    s# VARCHAR2(10),
    p# VARCHAR2(10),
    j# VARCHAR2(10),
    qty VARCHAR2(10)
) TABLESPACE tb_tarea;

-- Agregado de llave primaria
ALTER TABLE proveedores
ADD CONSTRAINT pk_proveedores 
PRIMARY KEY (s#);

ALTER TABLE partes
ADD CONSTRAINT pk_partes
PRIMARY KEY (p#);

ALTER TABLE envios
ADD CONSTRAINT pk_envios
PRIMARY KEY (s#, p#);

ALTER TABLE proyectos
ADD CONSTRAINT pk_proyectos
PRIMARY KEY (j#);

ALTER TABLE enviosproyectos 
ADD CONSTRAINT pk_enviosproyectos
PRIMARY KEY (s#, p#, j#);

-- Agregado de llaves foraneas

ALTER TABLE envios
ADD CONSTRAINT fk_envios_proveedores
FOREIGN KEY (s#) REFERENCES proveedores (s#);

ALTER TABLE envios
ADD CONSTRAINT fk_envios_partes
FOREIGN KEY (p#) REFERENCES partes (p#);

ALTER TABLE enviosproyectos
ADD CONSTRAINT fk_enviosproyectos_proveedores
FOREIGN KEY (s#) REFERENCES proveedores (s#);

ALTER TABLE enviosproyectos
ADD CONSTRAINT fk_enviosproyectos_partes
FOREIGN KEY (p#) REFERENCES partes (p#);

ALTER TABLE enviosproyectos
ADD CONSTRAINT fk_enviosproyectos_proyectos
FOREIGN KEY (j#) REFERENCES proyectos (j#);

-- Creado de procedimientos almacenados o funciones

-- Obtenga el color y ciudad para las partes que no son de París, con un peso mayor de diez.

CREATE OR REPLACE PROCEDURE obtener_partes_color_ciudad IS
BEGIN
    FOR rec in (
        SELECT color, city FROM partes WHERE city <>  'Paris' AND weight > 10
    ) LOOP
    
        DBMS_OUTPUT.PUT_LINE('Color: ' ||rec.color||', Ciudad: '||rec.city);
    END LOOP;
END;
/

BEGIN
  obtener_partes_color_ciudad;
END;
/

-- 4.1.2 Para todas las partes, obtenga el número de parte y el peso de dichas partes en gramos.

CREATE OR REPLACE PROCEDURE p_obtener_numparte_peso IS
BEGIN
    FOR rec in (SELECT p#, weight FROM partes) LOOP
        DBMS_OUTPUT.PUT_LINE('N°: '||rec.p#||', peso (gramos): '||rec.weight*453.592);
    END LOOP;
END;
/

BEGIN 
    p_obtener_numparte_peso;
END;
/

-- 4.1.3 Obtenga el detalle completo de todos los proveedores.

CREATE OR REPLACE PROCEDURE p_obtener_detalle_proveedores IS
BEGIN
    FOR rec in (SELECT * FROM proveedores ORDER BY s#) LOOP
        DBMS_OUTPUT.PUT_LINE('Id: '||rec.s#||', Nombre: '||rec.sname||', Status: '||rec.status||', Ciudad: '||rec.city);    
    END LOOP;
END;
/

BEGIN
    p_obtener_detalle_proveedores;
END;
/

-- 4.1.4 Obtenga todas las combinaciones de proveedores y partes para aquellos proveedores y partes co-localizados.

CREATE OR REPLACE PROCEDURE p_obtener_combinaciones IS
BEGIN
    FOR rec in (
        SELECT e.s#, e.p#, p.city FROM envios e
        JOIN partes p ON p.p# = e.p#
        JOIN proveedores pr ON pr.s# = e.s#
        WHERE pr.city = p.city
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('ID Proveedor: '||rec.s#||', ID Parte: '||rec.p#||', Ciudad compartida:'|| rec.city);
    END LOOP;
END;
/

BEGIN
   p_obtener_combinaciones;
END;
/

-- 4.1.5 Obtenga todos los pares de nombres de ciudades de tal forma que el proveedor 
-- localizado en la primera ciudad del par abastece una parte almacenada en la segunda ciudad del par.

CREATE OR REPLACE PROCEDURE p_pares_ciudades_abastecimiento IS
BEGIN
  FOR rec IN (
    SELECT DISTINCT s.city AS ciudad_proveedor, p.city AS ciudad_parte
    FROM envios e
    JOIN proveedores s ON e.s# = s.s#
    JOIN partes p ON e.p# = p.p#
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Proveedor en: ' || rec.ciudad_proveedor || ', Parte almacenada en: ' || rec.ciudad_parte);
  END LOOP;
END;
/
BEGIN
  p_pares_ciudades_abastecimiento;
END;
/

-- 4.1.6 Obtenga todos los pares de número de proveedor tales que los dos proveedores
-- del par estén co-localizados.

CREATE OR REPLACE PROCEDURE p_pares_proveedores_colocalizados IS
BEGIN
    FOR rec in (
        SELECT
            p1.s# as proveedor_1,
            p2.s# as proveedor_2,
            p1.city
        FROM
            proveedores p1
        JOIN
            proveedores p2
        ON 
            p1.city = p2.city
            AND p1.s# > p2.s#
        ORDER BY p1.city
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('ID Proveedor 1: '||rec.proveedor_1||', ID Proveedor 2: '||rec.proveedor_2||', Ciudad: '||rec.city);
    END LOOP;
END;
/

BEGIN
    p_pares_proveedores_colocalizados;
END;
/

-- 4.1.7 Obtenga el número total de proveedores.
CREATE OR REPLACE FUNCTION f_total_proveedores 
RETURN NUMBER IS
total_proveedores NUMBER;
BEGIN
    SELECT COUNT(*) INTO total_proveedores FROM proveedores;
    RETURN total_proveedores;
END;
/

DECLARE
    total NUMBER;
BEGIN
    total := f_total_proveedores;
    DBMS_OUTPUT.PUT_LINE('Total de proveedores: '||total);
END;
/

-- 4.1.8 Obtenga la cantidad mínima y la cantidad máxima para la parte P2.
CREATE OR REPLACE PROCEDURE p_min_max_cantidad_parte (
    id_parte IN VARCHAR2,
    min_qty OUT NUMBER,
    max_qty OUT NUMBER
) IS
BEGIN
    SELECT min(qty), max(qty) INTO min_qty, max_qty FROM envios WHERE p# = id_parte;
END;
/

DECLARE
    v_id_parte VARCHAR2(10) := '&id_parte';
    v_min_qty NUMBER;
    v_max_qty NUMBER;
BEGIN
    p_min_max_cantidad_parte(v_id_parte, v_min_qty, v_max_qty);
    DBMS_OUTPUT.PUT_LINE('Cantidad minima de '||v_id_parte||': '||v_min_qty);
    DBMS_OUTPUT.PUT_LINE('Cantidad maxima de '||v_id_parte||': '||v_max_qty);
END;
/

-- 4.1.9 Para cada parte abastecida, obtenga el número de parte y el total despachado.
CREATE OR REPLACE PROCEDURE p_obtener_total_por_parte IS
BEGIN
    FOR rec in (SELECT p#, SUM(qty) as total_cantidad FROM envios GROUP BY p#) LOOP
        DBMS_OUTPUT.PUT_LINE('ID parte: '||rec.p#||', Total despachado: '||rec.total_cantidad);
    END LOOP;
END;
/

BEGIN
    p_obtener_total_por_parte;
END;
/

-- 4.1.10 Obtenga el número de parte para todas las partes abastecidas por más de
-- un proveedor.

CREATE OR REPLACE PROCEDURE p_obtener_parte_abastecida IS
BEGIN
    FOR rec in (
        SELECT p#, COUNT(s#) as cantidad_proveedores
        FROM envios
        GROUP BY p#
        HAVING COUNT(DISTINCT s#) > 1
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('ID parte: '||rec.p#||', # de proveedores: '||rec.cantidad_proveedores);
    END LOOP;
END;
/

BEGIN
    p_obtener_parte_abastecida;
END;
/

-- 4.1.11 Obtenga el nombre de proveedor para todos los proveedores que abastecen
-- la parte P2.

SELECT sname FROM proveedores pr
JOIN envios e ON e.s#=pr.s#
WHERE e.p# = 'P2';

CREATE OR REPLACE PROCEDURE p_obtener_nombre_que_abastecen_parte (
    id_parte IN VARCHAR2
) IS 
BEGIN
    FOR rec in (
        SELECT sname FROM proveedores pr
        JOIN envios e ON e.s# = pr.s#
        WHERE e.p# = id_parte
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Nombre: '||rec.sname);
    END LOOP;
END;
/

DECLARE
    v_id_parte VARCHAR2(10):= '&id_parte';
BEGIN
    p_obtener_nombre_que_abastecen_parte(v_id_parte);
END;
/

-- 4.1.12 Obtenga el nombre de proveedor de quienes abastecen por lo menos una
-- parte.

SELECT pr.sname, COUNT(p#) as numero_de_abastecimiento FROM proveedores pr
JOIN envios e ON e.s# = pr.s#
GROUP BY pr.sname HAVING COUNT(p#) >= 1;

CREATE OR REPLACE PROCEDURE p_proveedores_multiples_partes IS
BEGIN
    FOR rec in (
        SELECT
            pr.sname, COUNT(p#) as numero_de_abastecimiento
        FROM proveedores pr
        JOIN envios e ON e.s# = pr.s#
        GROUP BY pr.sname HAVING COUNT(p#) >=1
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Nombre: '||rec.sname||', # de abastecimientos: '||rec.numero_de_abastecimiento);
    END LOOP;
END;
/

BEGIN
    p_proveedores_multiples_partes;
END;
/

-- 4.1.13 Obtenga el número de proveedor para los proveedores con estado menor
-- que el máximo valor de estado en la tabla S.

SELECT s# FROM proveedores WHERE status < (SELECT MAX(status) FROM proveedores);

CREATE OR REPLACE PROCEDURE p_obtener_proveedor_estado_menor 
IS
    v_max_status proveedores.status%TYPE;
BEGIN
    SELECT MAX(status) INTO v_max_status FROM proveedores;
    
    DBMS_OUTPUT.PUT_LINE('Max status: '||v_max_status);

    FOR rec in (SELECT s#, sname, status FROM proveedores WHERE status < v_max_status) LOOP
        DBMS_OUTPUT.PUT_LINE('ID: '||rec.s#||', Nombre: '||rec.sname||'Status: '||rec.status);
    END LOOP;
END;
/

BEGIN
    p_obtener_proveedor_estado_menor;
END;
/

-- 4.1.14 Obtenga el nombre de proveedor para los proveedores que abastecen la
-- parte P2 (aplicar EXISTS en su solución).

CREATE OR REPLACE PROCEDURE p_proveedores_que_abastecen_p2 IS
BEGIN
    FOR rec IN (
        SELECT pr.sname
        FROM proveedores pr
        WHERE EXISTS (
            SELECT 1
            FROM envios e
            WHERE e.s# = pr.s#
              AND e.p# = 'P2'
        )
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Proveedor: ' || rec.sname);
    END LOOP;
END;
/

BEGIN
    p_proveedores_que_abastecen_p2;
END;
/

-- 4.1.15 Obtenga el nombre de proveedor para los proveedores que no abastecen la
-- parte P2.

CREATE OR REPLACE PROCEDURE p_proveedores_que_no_abastecen_parte (
    p_parte_id IN VARCHAR2
) IS
BEGIN
    FOR rec IN (
        SELECT pr.sname
        FROM proveedores pr
        WHERE NOT EXISTS (
            SELECT 1
            FROM envios e
            WHERE e.s# = pr.s#
              AND e.p# = p_parte_id
        )
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Proveedor: ' || rec.sname);
    END LOOP;
END;
/

BEGIN
    p_proveedores_que_no_abastecen_parte('P2');
END;
/

-- 4.1.16 Obtenga el nombre de proveedor para los proveedores que abastecen todas
-- las partes.

SELECT pr.sname FROM proveedores pr
JOIN envios e ON e.s# = pr.s#
GROUP BY pr.sname HAVING COUNT(e.p#) = (SELECT COUNT(*) FROM partes);

CREATE OR REPLACE PROCEDURE p_proveedores_todas_partes IS
    v_total_partes NUMBER;
BEGIN
    
    SELECT COUNT(*) INTO v_total_partes FROM partes;

    FOR rec IN (
        SELECT pr.sname 
        FROM proveedores pr
        JOIN envios e ON e.s# = pr.s#
        GROUP BY pr.sname
        HAVING COUNT(e.p#) = v_total_partes
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Proveedor: ' || rec.sname);
    END LOOP;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Ningún proveedor abastece todas las partes.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No hay datos en las tablas proveedores o partes.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

EXEC p_proveedores_todas_partes;

-- 4.1.17 Obtenga el número de parte para todas las partes que pesan más de 16 libras
-- ó son abastecidas por el proveedor S2, ó cumplen con ambos criterios.

SELECT pa.p# FROM partes pa
JOIN envios e ON e.p# = pa.p#
WHERE pa.weight > 16 OR e.s# = 'S2';

CREATE OR REPLACE PROCEDURE p_obtener_num_parte_condicion
IS 
    v_peso partes.weight%type := 16;
    v_proveedor proveedores.s#%type := 'P2';
BEGIN
    FOR rec IN (
        SELECT DISTINCT pa.p# FROM partes pa
        JOIN envios e ON e.p# = pa.p#
        WHERE pa.weight > v_peso OR e.s# = v_proveedor
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('ID Parte: '||rec.p#);
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No hay datos en las tablas proveedores o partes.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

EXEC p_obtener_num_parte_condicion();
