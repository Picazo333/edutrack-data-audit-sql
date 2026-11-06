# Rúbrica — EduTrack, tablas relacionadas

Fuente: enunciado oficial `edutrack-data-audit-sql-related-tables` (README en inglés y en español). El enunciado manda sobre las notas de lanzamiento. Cada fila es un requisito. El estado está en `RUBRIC_JUSTIFICATION.md`.

El borrado en cascada se menciona en el enunciado como teoría del día y queda fuera de la rúbrica: no hay que probarlo.

| ID | Obligatorio | Criterio |
| --- | --- | --- |
| R01 | sí | El asset oficial `edutrack_v2.sql` está en el repositorio y no se ha modificado. |
| R02 | sí | Ese archivo se ejecuta entero y crea `students`, `courses` y `enrollments` con sus filas. |
| R03 | sí | La importación se comprueba con `SELECT * FROM enrollments LIMIT 5`, `SELECT * FROM students LIMIT 5` y `SELECT * FROM courses LIMIT 5`. |
| R04 | sí | Entrar en Supabase, usar un proyecto y lanzar el SQL en el SQL Editor. |
| R05 | sí | Modelar `students`, `courses` y `enrollments` en diagram.4geeks.com, con claves primarias, claves foráneas y tipos de relación. |
| R06 | sí | Exportar o capturar ese diagrama y dejarlo en la raíz como `diagram.png`. |
| R07 | sí | `diagram.png` representa las tres tablas, sus claves y los tipos de relación del esquema real. |
| R08 | sí | En el diagrama, las claves foráneas siguen la convención `table_name_id`. |
| R09 | sí | `queries.sql`, en la raíz, contiene las 10 consultas. |
| R10 | sí | Cada una de esas consultas usa al menos un JOIN. |
| R11 | sí | Ninguna usa subconsultas. |
| R12 | sí | INNER JOIN: cada inscripción con nombre del estudiante, título del curso y porcentaje de completado. |
| R13 | sí | INNER JOIN: nombre, email y título del curso de quien ha aprobado al menos un curso. |
| R14 | sí | INNER JOIN: promedio de completado por instructor, de mayor a menor. |
| R15 | sí | LEFT JOIN: estudiantes sin ninguna inscripción. |
| R16 | sí | LEFT JOIN: cursos sin ninguna inscripción. |
| R17 | sí | Agregación: cuántos cursos tiene cada estudiante, solo los que tienen más de uno, con `GROUP BY` y `HAVING`. |
| R18 | sí | Ingresos por categoría con `courses.monthly_fee`, no con el pago histórico de `enrollments`. |
| R19 | sí | Cada instructor junto al número de estudiantes inscritos en sus cursos. |
| R20 | sí | Inscripciones cuyo `student_id` no existe en `students`. |
| R21 | sí | Inscripciones cuyo `course_id` no existe en `courses`. |
| R22 | sí | Las consultas INNER JOIN solo devuelven filas con pareja en las dos tablas. |
| R23 | sí | Las consultas LEFT JOIN muestran las filas sin pareja en el lado derecho. |
| R24 | sí | Las 10 consultas se ejecutan sin error. La prueba de esta sesión es PostgreSQL local, el mismo dialecto. |
| R25 | sí | Esas consultas se ejecutan sin error en Supabase. |
| R26 | sí | `analysis_report.md`, en la raíz, tiene cada sección rellena con el resultado real de la consulta. |
| R27 | sí | `GROUP BY` + `HAVING` filtra el agregado (más de un curso). |
| R28 | sí | No usar herramientas de IA para generar las consultas SQL. |
| R29 | sí | `queries.sql`, `analysis_report.md` y `diagram.png` están en la raíz de un repositorio público. |
| R30 | sí | Compartir el repositorio con el instructor, siguiendo sus instrucciones de entrega. |
