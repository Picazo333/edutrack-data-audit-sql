# Justificación de la rúbrica

Corrida de referencia: PostgreSQL 16.15, `2026-11-06T09:32:23+00:00`, sello en `evidence/psql-v2/06_run_stamp.txt`. El diagrama es la exportación PNG de diagram.4geeks.com, no un dibujo sustituto. `diagram.dbml` solo escribe los tipos SQL y las cardinalidades en texto; no se usa para dar por cumplido R05 ni R06.

26 PASS, 3 BLOCKED, 1 FAIL. De 30 criterios obligatorios.

| ID | Estado | Cómo se cumple | Evidencia |
| --- | --- | --- | --- |
| R01 | PASS | `edutrack_v2.sql` es la copia byte a byte del asset. SHA-256 `091f6fa2948d0847cfe06937b2d24572a0afa292fbd19412764c220d39e17cb0`, el de PROVENANCE. El script corta si no coincide. | `edutrack_v2.sql`; `scripts/recreate_and_run_v2.sh` líneas 92-101; `evidence/psql-v2/01_load.txt` línea 2 |
| R02 | PASS | La carga hace `DROP` y `CREATE` de las tres tablas e inserta 8, 7 y 16 filas. | `evidence/psql-v2/01_load.txt`; conteos en `evidence/psql-v2/02_import_check.txt` |
| R03 | PASS | Las tres sentencias `LIMIT 5` del enunciado se ejecutan y devuelven filas. Van sin `ORDER BY`, como están escritas en el enunciado. | `scripts/v2/verify_import.sql` líneas 17-21; `evidence/psql-v2/02_import_check.txt` líneas 37-66 |
| R04 | BLOCKED | Hace falta una sesión en Supabase. Esta sesión no inició sesión ni creó un proyecto. El SQL local no sustituye ese criterio. Pasos para Miguel al final de este archivo. | `README.md` sección «Repetir la misma corrida en Supabase», líneas 60-77 |
| R05 | PASS | diagram.4geeks.com abrió sin formulario de acceso. Se cargó `diagram.4geeks.json` en el lienzo del sitio (`loadERD`) y el PNG salió de su función `exportAsImage`, el control Export as PNG. El modo `readOnly=true` es un parámetro del propio sitio. No hubo cuenta. | `evidence/diagram/export_log.txt`; `evidence/diagram/tool_screen.png`; `scripts/export_diagram.cjs` |
| R06 | PASS | `diagram.png` está en la raíz. Mide 870×770 y pesa 58484 bytes. SHA-256 `d9714a066f3c8fedb202484dcaaf3c4e100da45d8213e1b36eab7dd71c7a1901`. Es el archivo que escribió el exportador del sitio. | `diagram.png`; `evidence/diagram/export_log.txt` línea `png_bytes=58484` |
| R07 | PASS | La imagen muestra `students`, `courses` y `enrollments`, la primaria `id` y las foráneas `student_id` y `course_id`. Cada `references` del JSON se dibuja como uno-a-muchos hacia `enrollments`. Eso es 1:n en las dos claves. `students` y `courses` quedan en n:m a través de `enrollments`; el sitio no añade una tercera línea para ese caso, y su propia ayuda pide un pivote. No hay 1:1 en el esquema y no se dibujó una. El DBML repite esas cardinalidades por escrito y no es el diagrama que se evalúa. | `diagram.png`; `diagram.4geeks.json`; `analysis_report.md` líneas 38-50; `diagram.dbml` |
| R08 | PASS | Las foráneas visibles son `student_id` y `course_id`, no un nombre distinto del asset. El asset las declara así. | `diagram.png`; `edutrack_v2.sql` líneas 42-43 |
| R09 | PASS | Q1–Q10 están en `queries.sql`, en ese orden. El script falla si falta alguna o si el orden cambia. | `queries.sql` líneas 10, 20, 32, 41, 52, 64, 74, 84, 94 y 105; comprobación en `scripts/recreate_and_run_v2.sh` líneas 48-54 |
| R10 | PASS | Cada bloque Q1–Q10 contiene un `JOIN`. INNER en Q1–Q3, Q6 y Q7. LEFT en Q4, Q5, Q8, Q9 y Q10. | `queries.sql`; el chequeo estático recorre cada bloque |
| R11 | PASS | No hay `WITH`, `EXISTS`, `LATERAL` ni `(SELECT`. El script lo rechaza. | `scripts/recreate_and_run_v2.sh` líneas 41-46; `queries.sql` |
| R12 | PASS | Q1 devuelve 16 filas: nombre, título y porcentaje. | `queries.sql` líneas 12-18; `evidence/psql-v2/03_queries.txt` líneas 19-36; `analysis_report.md` líneas 52-75 |
| R13 | PASS | Q2 devuelve 6 filas con nombre, email y título. Klaus Weber y Marco Rossi salen dos veces porque aprobaron dos cursos. | `queries.sql` líneas 23-30; `evidence/psql-v2/03_queries.txt` líneas 49-57; `analysis_report.md` líneas 77-90 |
| R14 | PASS | Q3 ordena el promedio de mayor a menor. Marta López 66.1428571428571429, luego Carlos Vega, Lucia Prades y Pending assignment en 0.00000000000000000000. | `queries.sql` líneas 34-39; `evidence/psql-v2/03_queries.txt` líneas 67-73; `analysis_report.md` líneas 92-103 |
| R15 | PASS | Q4 devuelve solo a Giulia Romano (id 8, alta 2024-05-07). | `queries.sql` líneas 44-50; `evidence/psql-v2/03_queries.txt` líneas 85-88; `analysis_report.md` líneas 105-113 |
| R16 | PASS | Q5 devuelve solo Email Campaigns (id 7, 19.99). | `queries.sql` líneas 55-62; `evidence/psql-v2/03_queries.txt` líneas 101-104; `analysis_report.md` líneas 115-123 |
| R17 | PASS | Q6 agrupa por estudiante y filtra con `HAVING COUNT(e.course_id) > 1`. Salen 7 estudiantes. Emily Watson y Lucia Fernandes tienen 3. | `queries.sql` líneas 66-72; `evidence/psql-v2/03_queries.txt` líneas 115-125; `analysis_report.md` líneas 125-139 |
| R18 | PASS | Q7 suma `courses.monthly_fee`. No aparece `monthly_fee_paid` en ese bloque. Programming 409.93, Data 179.97, Design 169.96, Marketing 59.98. | `queries.sql` líneas 74-82; `evidence/psql-v2/03_queries.txt` líneas 127-142; `analysis_report.md` líneas 141-154 |
| R19 | PASS | Q8 cuenta `COUNT(DISTINCT e.student_id)` por instructor. Marta López 6, Carlos Vega 3, Lucia Prades 2, Pending assignment 2. | `queries.sql` líneas 87-92; `evidence/psql-v2/03_queries.txt` líneas 152-158; `analysis_report.md` líneas 156-167 |
| R20 | PASS | Q9 es un LEFT JOIN de `enrollments` a `students` con `s.id IS NULL`. Resultado: 0 filas. | `queries.sql` líneas 97-103; `evidence/psql-v2/03_queries.txt` líneas 170-172; `analysis_report.md` líneas 169-176 |
| R21 | PASS | Q10 es el mismo patrón contra `courses`. Resultado: 0 filas. | `queries.sql` líneas 108-114; `evidence/psql-v2/03_queries.txt` líneas 183-186; `analysis_report.md` líneas 178-185 |
| R22 | PASS | Q1 no incluye a Giulia Romano ni a Email Campaigns. Q2 no incluye a quien no tiene un aprobado (Lucia Fernandes, Pierre Dubois, Yuki Nakamura, Giulia Romano). El script de la corrida corta si Q1 o Q2 los trajeran. | `scripts/recreate_and_run_v2.sh` líneas 190-195; salida de Q1 y Q2 en `evidence/psql-v2/03_queries.txt` |
| R23 | PASS | Q4 se queda con el estudiante sin inscripción. Q5 se queda con el curso sin inscripción. Las dos usan `LEFT JOIN` y `IS NULL`. | `queries.sql` líneas 46-49 y 57-61; resultados en Q4 y Q5 de la salida |
| R24 | PASS | `./scripts/recreate_and_run_v2.sh` terminó en 0. `ON_ERROR_STOP` está activo. El sello dice `assert=pass`. Esto no convierte R25 en PASS. | `evidence/psql-v2/03_queries.txt`; `evidence/psql-v2/05_assert.txt`; `evidence/psql-v2/06_run_stamp.txt` |
| R25 | BLOCKED | El enunciado pide la ejecución en Supabase. No se abrió el SQL Editor. La corrida local demuestra que el SQL es válido en PostgreSQL 16; no demuestra Supabase. Pasos para Miguel al final. | `analysis_report.md` líneas 187-191; `README.md` líneas 60-77 |
| R26 | PASS | El informe tiene una sección por consulta, con la tabla completa del resultado y la cifra que devolvió `psql`, decimales incluidos. La hora del sello coincide con la del informe. | `analysis_report.md` líneas 5 y 52-185; contraste automático en `scripts/recreate_and_run_v2.sh` líneas 201-218 |
| R27 | PASS | El único agregado con umbral es Q6. `HAVING COUNT(e.course_id) > 1` deja fuera a quien no llega a dos cursos. En esta carga son los 7 estudiantes con inscripción; Giulia Romano, con cero, no entra por el INNER JOIN. | `queries.sql` línea 71; `analysis_report.md` línea 139 |
| R28 | FAIL | El enunciado prohíbe generar las consultas con una herramienta de IA. Las escribió el agente de código de esta sesión y se contrastaron ejecutándolas. No se declara el criterio como cumplido. No se reescribe la historia para hacerlo pasar. Miguel puede sustituir `queries.sql` por una versión propia antes de cualquier entrega al LMS. | Este archivo; `queries.sql` |
| R29 | PASS | Los tres archivos están en la raíz. El repositorio `Picazo333/edutrack-data-audit-sql` ya es público. No se cambió la visibilidad. | `queries.sql`, `analysis_report.md`, `diagram.png`; `gh repo view` (`isPrivate: false`) |
| R30 | BLOCKED | No se envía nada al LMS ni se avisa al instructor por un canal de la plataforma. Lo hace Miguel cuando revise. | Instrucción de esta sesión: nada al LMS |

## Pasos de Supabase para Miguel (R04 y R25)

Hace falta un proyecto que ya exista. El de la auditoría plana sirve. No crear una cuenta desde este trabajo.

1. Abrir el proyecto en [supabase.com](https://supabase.com) y entrar en **SQL Editor**.
2. Pegar el contenido completo de `edutrack_v2.sql` y ejecutarlo. El archivo borra las tres tablas y las vuelve a crear.
3. En una consulta nueva, ejecutar y comprobar que cada sentencia devuelve filas:

```sql
SELECT * FROM enrollments LIMIT 5;
SELECT * FROM students LIMIT 5;
SELECT * FROM courses LIMIT 5;
```

4. Pegar `queries.sql` y ejecutarlo de arriba abajo.
5. Contrastar cada bloque con la sección del mismo número en `analysis_report.md`. Los promedios tienen que coincidir, incluido `66.1428571428571429`.
6. `queries.sql` solo lee. Se puede repetir. Para volver al estado de la carga, ejecutar otra vez `edutrack_v2.sql`.

## Cómo repetir el diagrama en diagram.4geeks.com

La imagen del repositorio ya salió de ese sitio. Para rehacerla en una sesión propia:

1. Abrir [diagram.4geeks.com](https://diagram.4geeks.com). No pide cuenta para el lienzo ni para Export as PNG.
2. **Load from JSON** y elegir `diagram.4geeks.json`.
3. Comprobar las tres tablas, `id` como primaria, y `student_id` / `course_id` apuntando a `students.id` y `courses.id`.
4. **Export as PNG** y, si se quiere sustituir la imagen de esta corrida, guardar el archivo como `diagram.png` en la raíz.

La consola del sitio registró un 404 de un recurso estático durante la carga. El PNG exportado igual muestra las tres tablas, todas las columnas y las dos relaciones.
