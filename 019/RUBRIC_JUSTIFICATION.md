# Justificación de la rúbrica — EduTrack Data Audit

Commit: `e446d9883294325009f58099e34a37c738a8322c`
Rama: `cursor/edutrack-data-audit-f76c`
Pull request: https://github.com/Picazo333/edutrack-data-audit-sql/pull/1
Motor: PostgreSQL 16.15 local. Corrida de evidencia: `2026-11-06T09:12:56+00:00`, `assert=pass`.

Resultado de lo puntuable: **29/31 PASS**, **0 FAIL**, **1 BLOCKED_HITL** (R30), **1 HITL_MIGUEL** (R31).

29 + 0 + 1 + 1 = 31.

Verificación de esta pasada: `./scripts/recreate_and_run.sh` el `2026-11-06T14:47:58+00:00`, `assert=pass`. La salida de Q1–Q12 coincide con `evidence/psql/04_queries.txt`. `queries.sql` sigue en sha256 `3af333ff5e4bef38e30389c17e2feb1e8a03308b3cccb10d9a699c7d6ccbe6e0`.

## A. Enunciado

| ID | Estado | Cómo se cumple | Evidencia |
| --- | --- | --- | --- |
| R01 | PASS | `queries.sql` está en la raíz y contiene Q1–Q12. | `queries.sql:1` y `queries.sql:11`–`queries.sql:206`. Commit `e446d98`. |
| R02 | PASS | `analysis_report.md` está en la raíz. | `analysis_report.md:1`. |
| R03 | PASS | El script recrea la base y carga el `edutrack.sql` oficial. La carga termina en `INSERT 0 17` para `enrollments`, sin error. | `scripts/recreate_and_run.sh` (paso de carga). `evidence/psql/01_load.txt:2` (sha256) y el `INSERT 0 17` de ese archivo. |
| R04 | PASS | Tras la carga existen las tres tablas y tienen filas: `courses` 7, `enrollments` 17, `students` 10. `SELECT * FROM enrollments LIMIT 5` devuelve 5 filas. | `evidence/psql/02_import_check.txt` (lista `\dt`, conteos y las 5 primeras filas). |
| R05 | PASS | Q1 filtra `course_title = 'Intro to Python'` y devuelve nombre, email y porcentaje. Resultado real: 5 filas. | `queries.sql:11`–`queries.sql:18`. Informe `analysis_report.md:25`. Salida en `evidence/psql/04_queries.txt` (primer result set, `(5 rows)`). |
| R06 | PASS | Q2 filtra `completion_percentage < 10`. Resultado real: 4 filas (ids 10, 11, 6 y 5). Alex Chen, con avance 10, queda fuera. | `queries.sql:21`–`queries.sql:29`. Informe `analysis_report.md:39`. Misma salida en `04_queries.txt`. |
| R07 | PASS | Q3 filtra `instructor IS NULL`. Resultado real: 2 filas, ids 10 y 11, ambas de UI/UX Fundamentals. | `queries.sql:32`–`queries.sql:40`. Informe `analysis_report.md:52`. |
| R08 | PASS | Q4 filtra `passed = FALSE`, ordena por avance descendente y corta con `LIMIT 5`. Resultado real: Emily 60, Priya 55, Yuki 45, Emily 40, James 30. | `queries.sql:43`–`queries.sql:54`. Informe `analysis_report.md:63`. |
| R09 | PASS | Q5 usa `enrollment_date >= DATE '2024-07-01'` y `ORDER BY enrollment_date DESC`. Resultado real: 9 filas, de `2025-03-05` a `2024-07-01` inclusive. | `queries.sql:57`–`queries.sql:65`. Informe `analysis_report.md:77`. |
| R10 | PASS | Q6 inserta `id = 18` con los doce campos del comentario `MISSING RECORD`. La comprobación previa devolvió 0 filas. La etiqueta fue `INSERT 0 1`. La aserción compara nombre, email, curso, fecha, avance 0, `passed` false, cuota 69.99 e instructor Carlos Vega. | Valores fuente: `edutrack.sql:109`–`edutrack.sql:127`. Consulta: `queries.sql:68`–`queries.sql:126`. Etiqueta: `evidence/psql/04_queries.txt:57`. Aserción: `scripts/assert_after.sql` (bloque Q6) y `evidence/psql/06_assert.txt` (`DO` sin excepción). Informe: `analysis_report.md:95`. |
| R11 | PASS | Q7 hace `SET instructor = 'Pending assignment'` solo con `WHERE instructor IS NULL`. Etiqueta `UPDATE 2`. Las filas devueltas son la 10 y la 11. La fila 1 sigue con Marta López (lo comprueba la aserción). | `queries.sql:140`–`queries.sql:142`. `evidence/psql/04_queries.txt:70`. Informe `analysis_report.md:107`. |
| R12 | PASS | Q8 borra con `student_email LIKE '%@test.com'`. Etiqueta `DELETE 2`: James Miller (id 13, Intro to Python, 49.99) y Alex Chen (id 14, Web Design Basics, 39.99). La aserción exige que esas ids no sigan en `enrollments` y que las cuentas sigan en `students`. | `queries.sql:165`–`queries.sql:166`. `evidence/psql/04_queries.txt:83`. Informe `analysis_report.md:120`. |
| R13 | PASS | El `SELECT` de Q7 (`queries.sql:130`) está antes del `UPDATE` (`queries.sql:140`) y usa el mismo `WHERE instructor IS NULL`. El `SELECT` de Q8 (`queries.sql:153`) está antes del `DELETE` (`queries.sql:165`) y usa el mismo `LIKE '%@test.com'`. El script de reproducción falla si ese orden no se cumple. | Esas líneas, más la comprobación estática en `scripts/recreate_and_run.sh` (mensaje `comprobación estática de queries.sql: ok` en la corrida). |
| R14 | PASS | Los comentarios `-- Q1:` … `-- Q12:` aparecen en orden creciente. | `queries.sql:11`, `:21`, `:32`, `:43`, `:57`, `:68`, `:128`, `:150`, `:176`, `:184`, `:192`, `:201`. |
| R15 | PASS | Q9 empieza en `queries.sql:176`, después del `DELETE` de Q8 (`queries.sql:165`). Los agregados del informe son los de después: Programming 7 / Design 4 / Data 3 / Marketing 2, no los de la foto previa (Design 5). | `queries.sql:176`. Foto previa: `evidence/psql/03_snapshot_before.txt`. Resultado Q9–Q12: `evidence/psql/04_queries.txt` y `evidence/psql/05_snapshot_after.txt`. |
| R16 | PASS | Q9 es `COUNT(*)` con `GROUP BY category`. | `queries.sql:177`–`queries.sql:181`. Informe `analysis_report.md:133`. |
| R17 | PASS | Q10 es `AVG(completion_percentage)` con `GROUP BY course_title` y `ORDER BY` ascendente. Seis cursos, de UI/UX en 0 a Intro to Python en 80. | `queries.sql:185`–`queries.sql:189`. Informe `analysis_report.md:151`. |
| R18 | PASS | Q11 agrupa por curso y filtra con `HAVING COUNT(*) > 3`. Una fila: Intro to Python, 4. Data y Advanced Python se quedan en 3 y no salen. | `queries.sql:193`–`queries.sql:198`. Informe `analysis_report.md:166`. |
| R19 | PASS | Q12 es `SUM(monthly_fee_paid)` con `GROUP BY category` y `ORDER BY total_revenue DESC`. Programming 409.93, Data 179.97, Design 169.96, Marketing 59.98. | `queries.sql:202`–`queries.sql:206`. Informe `analysis_report.md:176`. |
| R20 | PASS | Cada bloque lleva un comentario `-- Qn:`. | Las líneas de R14. |
| R21 | PASS | Las 12 consultas están en `queries.sql` y la corrida local termina sin error. `ON_ERROR_STOP` está activo. Esto no da por hecha la ejecución dentro de Supabase: eso es R30. | `evidence/psql/04_queries.txt` completo. `evidence/psql/07_run_stamp.txt:10` (`assert=pass`). `evidence/psql/06_assert.txt`. |
| R22 | PASS | Cada tabla del informe se contrastó con `04_queries.txt` y con las fotos de antes y después. Una comprobación automática buscó en el informe y en la salida las cifras 409.93, 179.97, 169.96, 59.98, los promedios largos de `AVG`, `INSERT 0 1`, `UPDATE 2`, `DELETE 2` y `Pending assignment`. No faltó ninguna. | `analysis_report.md` frente a `evidence/psql/04_queries.txt`, `03_snapshot_before.txt` y `05_snapshot_after.txt`. |
| R23 | PASS | Hay una sección por consulta, de Q1 a Q12, y cada una abre con `Resultado:` y los números de la corrida. Ninguna sección quedó en blanco. | `analysis_report.md:25`, `:39`, `:52`, `:63`, `:77`, `:95`, `:107`, `:120`, `:133`, `:151`, `:166`, `:176`. |
| R24 | PASS | `queries.sql` no tiene `INSERT`/`UPDATE`/`DELETE` sobre `students` ni `courses`. El hash de ambas tablas es el mismo antes y después. Los conteos siguen en 10 y 7. Las cuentas `@test.com` siguen en `students`. | Comprobación estática del script. `evidence/psql/07_run_stamp.txt` (`students_hash` y `courses_hash`). Aserción en `scripts/assert_after.sql`. |
| R25 | PASS | El SHA-256 del archivo cargado es el de `PROVENANCE.json`: `faebf83f72bbf95d7ef55aad78f36fc9168891c36e8994eeb4a65629086e3387`. El script aborta si no coincide. La fila 18 sale de ese comentario, no de una fila inventada. | `evidence/psql/01_load.txt:2`. `evidence/psql/07_run_stamp.txt:4`. `edutrack.sql:109`–`edutrack.sql:127`. |
| R26 | PASS | `queries.sql` es SQL de PostgreSQL: `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `GROUP BY`, `HAVING`, `AVG`, `SUM`, `COUNT`, `DATE '...'`, `IS NULL`, `LIKE`, `RETURNING`. No hay metacomandos `\dt` ni sintaxis de otro motor. `SET datestyle` solo fija el formato de la sesión. | `queries.sql:8` y el resto del archivo. La comprobación estática rechaza una línea que empiece por `\`. |
| R31 | HITL_MIGUEL | Criterio del enunciado, `OFFICIAL_README.md` línea 116. Declaración de autoría/uso de herramientas al entregar: decisión de Miguel. | `OFFICIAL_README.md:116`. `EVAL.md`. |

## B. Supabase

| ID | Estado | Cómo se cumple | Evidencia |
| --- | --- | --- | --- |
| R30 | BLOCKED_HITL | El enunciado pide importar `edutrack.sql` en un proyecto Supabase y ejecutar las consultas en el SQL Editor. En esta corrida no hay cuenta ni credenciales, y no se crea una cuenta. El SQL ya está escrito para pegarlo allí. Los pasos, en el mismo orden, están en el README: (1) abrir el proyecto y el SQL Editor, (2) pegar y ejecutar `edutrack.sql`, (3) `SELECT * FROM enrollments LIMIT 5`, (4) pegar y ejecutar `queries.sql` una sola vez, (5) contrastar cada bloque con la sección del mismo número en `analysis_report.md`, (6) para repetir, volver a lanzar `edutrack.sql` y después `queries.sql`, (7) no escribir en `students` ni en `courses`. | Motivo de bloqueo: ausencia de cuenta. Pasos: `README.md:49`–`README.md:61`. La prueba sustituta de que el SQL corre es R21, en PostgreSQL 16.15, y no convierte R30 en PASS. |

## C. Entrega

| ID | Estado | Cómo se cumple | Evidencia |
| --- | --- | --- | --- |
| R27 | PASS | El trabajo está en `cursor/edutrack-data-audit-f76c` y el pull request contra `main` es el número 1. No se hizo merge. | https://github.com/Picazo333/edutrack-data-audit-sql/pull/1. Commit `e446d9883294325009f58099e34a37c738a8322c`. |
| R28 | PASS | El README dice qué es el proyecto, la estructura, cómo lanzar el script, las decisiones de las consultas y los pasos de Supabase. No añade colaboradores ni una autoría inventada. | `README.md:1`–`README.md:61`. |
| R29 | PASS | No se envió el repositorio al LMS ni a ninguna plataforma de entrega del curso. El enlace de la vista del curso queda para Miguel. | Esta corrida no llama a ningún endpoint del LMS. Los criterios que siguen abiertos están en `FINAL_AUDIT.md`: R30 y R31. |

## D. Extras

| ID | Estado | Cómo se cumple | Evidencia |
| --- | --- | --- | --- |
| E01 | PASS | El informe tiene una tabla de hallazgos en cada Q y una sección de antes y después de Q6–Q8: conteos, ingresos, promedios, el curso por encima de 3 inscripciones, y la repetición de los filtros de Q1, Q2, Q4 y Q5. | `analysis_report.md:194`–`analysis_report.md:255`. Fotos: `evidence/psql/03_snapshot_before.txt`, `03b_filters_before.txt`, `05_snapshot_after.txt`, `05b_filters_after.txt`. |
| E02 | PASS | `queries.sql` va numerado, con comentario por consulta y un `SELECT` de verificación antes del `UPDATE` y del `DELETE`. `scripts/recreate_and_run.sh` borra la base, la recrea, carga el dump oficial, corre todo y lanza `scripts/assert_after.sql`. | `queries.sql:130` y `queries.sql:153`. `scripts/recreate_and_run.sh`. `scripts/assert_after.sql`. `evidence/psql/06_assert.txt` y `07_run_stamp.txt:10`. |

## E. SIGNAL

| ID | Estado | Cómo se cumple | Evidencia |
| --- | --- | --- | --- |
| S01 | PASS | El informe tiene un título, un párrafo de alcance, el orden de lectura, un resumen con las cifras que cambian la decisión, doce secciones con el mismo patrón (`Resultado` y tabla) y el antes/después separado al final. | `analysis_report.md:1`, `:9`, `:13` y las secciones Q1–Q12. `DESIGN-QA.md`. |
| S02 | NO APLICA | No hay interfaz. El lockup 4Geeks × Divinivid no se pinta en un footer que no existe. | `DESIGN-QA.md`. |
| S03 | PASS | `DESIGN-QA.md` registra el alcance sin UI y la revisión de jerarquía del informe. | `/opt/cursor/artifacts/DESIGN-QA.md`. |
| S04 | NO APLICA | No hay pantallas que capturar a 390, 768 o 1280 px, ni un recorrido en vídeo, ni un build al que pasar Lighthouse. | `DESIGN-QA.md`. |
| S05 | NO APLICA | `SIGNAL_BRIEF.md` y `SIGNAL_PACKAGE.zip` no están en esta corrida. No se inventan hashes. | `DESIGN-QA.md`. |

## Lectura de Q4

Q4 pide las cinco inscripciones no aprobadas con mayor `completion_percentage`. La consulta ordena filas de `enrollments` y aplica `LIMIT 5`. Emily Watson aparece dos veces porque tiene dos cursos sin aprobar. El informe lo dice en `analysis_report.md:75`.
