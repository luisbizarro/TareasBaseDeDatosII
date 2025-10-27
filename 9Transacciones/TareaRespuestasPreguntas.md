Tarea 9
# III. EJERCICIOS PLANTEADOS DE BLOQUES ANÓNIMOS

1. Ejercicio 1 – Control básico de transacciones
Cree un bloque anónimo PL/SQL que:
- Aumente en un 10% el salario de los empleados del departamento 90.
- Guarde un `SAVEPOINT` llamado punto1.
- Aumente en un 5% el salario de los empleados del departamento 60.
- Realice un `ROLLBACK` al `SAVEPOINT` punto1.
- Ejecute finalmente un COMMIT.
Preguntas:
a. ¿Qué departamento mantuvo los cambios?
Solo el departamento de id = 90
b. ¿Qué efecto tuvo el ROLLBACK parcial?
Pues fue como un punto de partida para volver antes de ejecutar dicha acción.
c. ¿Qué ocurriría si se ejecutara ROLLBACK sin especificar SAVEPOINT?
Se desharían todos los cambios realizados en la transacción actual, incluyendo los del departamento 90, y no se guardarían en la base de datos.
---
2. Ejercicio 2 – Bloqueos entre sesiones
En dos sesiones diferentes de Oracle:
• En la primera sesión, ejecute:
~~~sql
UPDATE employees
SET salary = salary + 500
WHERE employee_id = 103;
~~~
- Sin ejecutar COMMIT, en la segunda sesión, intente modificar el mismo registro.
- Observe el bloqueo y, desde la primera sesión, ejecute: `ROLLBACK`;
- Analice el efecto sobre la segunda sesión.
Preguntas:
a. ¿Por qué la segunda sesión quedó bloqueada?
Porque la primera sesión hizo un cambio sobre el registro sin hacer COMMIT o ROLLBACK.
b. ¿Qué comando libera los bloqueos?
ROLLBACK o COMMIT
c. ¿Qué vistas del diccionario permiten verificar sesiones bloqueadas?
Las vistas principales en Oracle que puedes usar para monitorear bloqueos son:
`V$LOCK`: Muestra los bloqueos actuales en la base de datos.
`V$SESSION`: Información sobre las sesiones actuales.
`V$LOCKED_OBJECT`: Muestra los objetos bloqueados.
`DBA_BLOCKERS` y `DBA_WAITERS`: muestran sesiones que bloquean y esperan respectivamente.

---
3. Ejercicio 3 – Transacción controlada con bloque PL/SQL
Cree un bloque anónimo PL/SQL que realice una transferencia de empleado de un
departamento a otro, registrando la transacción en JOB_HISTORY.
- Actualice el department_id del empleado 104 al departamento 110.
- Inserte simultáneamente el registro correspondiente en JOB_HISTORY.
- Si ocurre un error (por ejemplo, departamento inexistente), haga un ROLLBACK y
muestre un mensaje con DBMS_OUTPUT.
Preguntas:
a. ¿Por qué se debe garantizar la atomicidad entre las dos operaciones?
Porque ambas operaciones forman parte de una única transacción lógica: cambiar el departamento del empleado y registrar ese cambio en el historial. Si una de ellas falla, no debería afectar que la otra quede aplicada, evitando inconsistencias en los datos.
b. ¿Qué pasaría si se produce un error antes del COMMIT?
Si ocurre un error, se ejecutará el ROLLBACK que deshace todos los cambios realizados en la transacción actual, manteniendo la integridad y consistencia de los datos.
c. ¿Cómo se asegura la integridad entre EMPLOYEES y JOB_HISTORY?
En que si una operación falla, se revierte todo y no se dejan datos parciales que invaliden la relación entre tablas.
---
4. Ejercicio 4 – SAVEPOINT y reversión parcial
Diseñe un bloque anónimo PL/SQL que ejecute las siguientes operaciones en una sola
transacción:
- Aumentar el salario en 8% para empleados del departamento 100 → SAVEPOINT A.
- Aumentar el salario en 5% para empleados del departamento 80 → SAVEPOINT B.
- Eliminar los empleados del departamento 50.
- Revierte los cambios hasta el SAVEPOINT B.
- Finalmente, confirma la transacción con COMMIT.
Preguntas:
a. ¿Qué cambios quedan persistentes?
Quedan persistentes los aumentos del 8% en el departamento 100 y el 5% en el departamento 80, ya que la reversión con ROLLBACK TO SAVEPOINT B deshace sólo la eliminación de empleados en el departamento 50.
b. ¿Qué sucede con las filas eliminadas?
Las filas eliminadas del departamento 50 no quedan eliminadas porque el rollback parcial revierte esa eliminación, devolviendo esos empleados a la tabla.
c. ¿Cómo puedes verificar los cambios antes y después del COMMIT?
Antes del COMMIT, puedes hacer consultas en la misma sesión para ver los cambios (los cambios son visibles en la transacción actual).
