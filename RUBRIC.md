# Rúbrica — EduTrack Data Audit (edutrack-data-audit-sql)

Fuente de autoridad: `OFFICIAL_README.md` / `OFFICIAL_README.es.md` (syllabus `edutrack-data-audit-sql` @ `fd2da034894ba93ba738559280ccde074ab1d953`). Asset de datos: `edutrack.sql` (sha256 `faebf83f72bbf95d7ef55aad78f36fc9168891c36e8994eeb4a65629086e3387`).

Reglas de fase 2 y del encargo: sin cuenta Supabase; PostgreSQL local; sin merge; sin envío al LMS; extras visible y técnico; SIGNAL solo en claridad y jerarquía del informe.

Estado de cada criterio se cierra en `RUBRIC_JUSTIFICATION.md` después de la evidencia. Aquí solo se fija el criterio, antes de implementar.

## A. Enunciado — obligatorios

| ID | Required | Criterio |
| --- | --- | --- |
| R01 | sí | `queries.sql` está en la raíz del repositorio. |
| R02 | sí | `analysis_report.md` está en la raíz del repositorio. |
| R03 | sí | Se importa el `edutrack.sql` oficial, sin alterar su contenido, y la carga termina sin error. |
| R04 | sí | Tras la carga, existen `enrollments`, `students` y `courses`, y las tres contienen filas. |
| R05 | sí | Q1 lista las inscripciones de `'Intro to Python'` y muestra nombre, email y porcentaje de completado. |
| R06 | sí | Q2 devuelve las inscripciones con `completion_percentage` menor que 10. |
| R07 | sí | Q3 devuelve las inscripciones con `instructor` NULL. |
| R08 | sí | Q4 lista las 5 inscripciones no aprobadas (`passed = false`) con mayor `completion_percentage`. |
| R09 | sí | Q5 muestra inscripciones con `enrollment_date` en o después de `'2024-07-01'`, ordenadas por esa fecha descendente. |
| R10 | sí | Q6 inserta la inscripción que falta, con `id = 18` y exactamente los valores del comentario de `edutrack.sql`. No se inventan filas. |
| R11 | sí | Q7 actualiza solo las filas con `instructor` NULL y les asigna `'Pending assignment'`. |
| R12 | sí | Q8 borra solo inscripciones de cuentas `@test.com` y ninguna otra fila de `enrollments`. |
| R13 | sí | Antes del UPDATE (Q7) y antes del DELETE (Q8) hay un SELECT con el mismo filtro, para confirmar las filas. |
| R14 | sí | Las consultas están escritas y se ejecutan en orden Q1 → Q12. |
| R15 | sí | Las agregaciones Q9–Q12 se calculan después de las correcciones Q6–Q8. |
| R16 | sí | Q9 cuenta inscripciones con `GROUP BY category`. |
| R17 | sí | Q10 calcula el promedio de `completion_percentage` con `GROUP BY course_title`, de menor a mayor. |
| R18 | sí | Q11 muestra solo los cursos con más de 3 inscripciones y usa `HAVING`. |
| R19 | sí | Q12 suma `monthly_fee_paid` con `GROUP BY category`, de mayor a menor. |
| R20 | sí | Cada consulta lleva en `queries.sql` un comentario con su número (Q1…Q12). |
| R21 | sí | Las 12 consultas están en `queries.sql` y se ejecutan sin error. La prueba de esta corrida es PostgreSQL local, dialecto compatible con Supabase. La ejecución dentro de un proyecto Supabase es R30 y no se da por cumplida aquí. |
| R22 | sí | Los SELECT devuelven las filas y columnas que piden las condiciones del enunciado. Los números del informe salen de esa salida, no de un cálculo manual sin ejecutar. |
| R23 | sí | `analysis_report.md` tiene una sección por cada consulta Q1–Q12, con el resultado real rellenado (nada en blanco). |
| R24 | sí | No se modifican `students` ni `courses` (ni datos ni estructura). |
| R25 | sí | El archivo de carga usado es el asset oficial (mismo sha256 que `PROVENANCE.json`). |
| R26 | sí | `queries.sql` es SQL de PostgreSQL válido en Supabase: sin metacomandos `psql` (`\dt`, `\echo`), sin sintaxis de otro motor. |
| R31 | sí | No usar herramientas de IA para generar las consultas SQL. Escribir cada una uno mismo. Cita literal de `OFFICIAL_README.md`, línea 116: "Do not use AI tools to generate your SQL queries. Write each one yourself." |

## B. Entorno nombrado por el enunciado

| ID | Required | Criterio |
| --- | --- | --- |
| R30 | sí | Importar `edutrack.sql` en un proyecto Supabase y ejecutar las consultas en el SQL Editor de Supabase. |

R30 exige explícitamente Supabase (proyecto y SQL Editor). Sin cuenta ni credenciales no se crea una cuenta. Queda **BLOCKED_HITL** hasta que Miguel lo reproduzca. Los pasos exactos se documentan en el README y en `FINAL_AUDIT.md`.

## C. Entrega

| ID | Required | Criterio |
| --- | --- | --- |
| R27 | sí | El trabajo va en una rama y se abre un pull request contra `main`. No se hace merge. |
| R28 | sí | El README del repo es técnico y neutral: qué es el proyecto, cómo ejecutarlo, estructura y decisiones. Sin colaboradores ni autoría inventada. |
| R29 | sí (restricción) | No se envía nada al LMS ni a plataformas externas. El envío del enlace en la vista del curso queda para Miguel. |

## D. Excelencia (fase 2)

No sustituyen a un obligatorio. Deben existir además de la rúbrica.

| ID | Required | Criterio |
| --- | --- | --- |
| E01 | extra visible | `analysis_report.md` incluye tablas de hallazgos Q1–Q12 y el antes y después de las correcciones Q6–Q8. |
| E02 | extra técnico | `queries.sql` numerado, con comentarios y SELECT de verificación antes de cada UPDATE o DELETE, más un script que recrea la base desde cero y corre la auditoría de forma reproducible, con aserciones al final. |

## E. SIGNAL (sin UI)

| ID | Required | Criterio |
| --- | --- | --- |
| S01 | sí, en el informe | Claridad y jerarquía: un título, resumen con los hallazgos que importan, una sección homogénea por consulta, tablas legibles, y el antes/después separado del resultado de cada query. |
| S02 | no aplica | Lockup 4Geeks × Divinivid. No hay interfaz. Se documenta y no se inventa un footer. |
| S03 | sí, artifact | `DESIGN-QA.md` mínimo que registre el alcance (sin UI) y cómo se aplicó S01. |
| S04 | no aplica | Capturas 390/768/1280, vídeo y Lighthouse. No hay interfaz que medir. |
| S05 | no aplica | Verificación de hashes de `SIGNAL_PACKAGE.zip`. El paquete y `SIGNAL_BRIEF.md` no están en esta corrida. No se inventan hashes. |

## Fuera de la rúbrica (no se puntúa como FAIL)

- La estructura interna de `students` y `courses` no se evalúa. Solo se comprueba que esta entrega no las modifica.

R31 es obligatorio. Estado: **HITL_MIGUEL**. Nota: declaración de autoría/uso de herramientas al entregar: decisión de Miguel.
