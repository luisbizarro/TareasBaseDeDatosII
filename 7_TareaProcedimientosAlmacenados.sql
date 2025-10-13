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
