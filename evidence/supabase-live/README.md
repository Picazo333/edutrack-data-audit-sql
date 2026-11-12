# 019: corrida en Supabase (proyecto 4geeks-cohorte, ref atraotgdztnrqystnujh)

Fecha: 2026-11-06 11:58:33 CST. Postgres 17.11 de Supabase. Ejecutado con el conector oficial de Supabase (apply_migration y execute_sql), sobre el mismo motor y proyecto que usa el SQL Editor. Miguel lo autorizó en sus propias palabras a las 11:52 CST.

- Migración `edutrack_019_load_official`: `edutrack.sql` oficial (sha256 `faebf83f…3387`, igual a PROVENANCE) cargado en el schema aislado `edutrack_019`. Se usa un schema aparte para no chocar con 020, que usa los mismos nombres de tabla. Copia exacta: `00-migration-applied.sql`.
- Importación: tablas courses, enrollments y students, con 7, 17 y 10 filas; `SELECT * FROM enrollments LIMIT 5` devuelve 5 filas.
- `queries.sql` Q1–Q12, en orden: filas 5, 4, 2, 5 y 9; Q6 sin la fila id 18 antes del INSERT y 1 fila insertada; Q7 con 2 filas y UPDATE 2; Q8 con 2 filas y DELETE 2; Q9–Q12 con 4, 6, 1 y 4 filas. Coincide fila por fila con `evidence/psql/04_queries.txt` de PostgreSQL 16 local. Q12 da Programming 409.93, Data 179.97, Design 169.96 y Marketing 59.98.
- Invariantes: students y courses tienen el mismo md5 antes y después (`9040195f…` y `13ff18ac…`); enrollments queda en 16. `scripts/assert_after.sql` (con students_before=10 y courses_before=7) devuelve `assert_after_019=pass`.
- Salida completa: `01-results-Q1-Q12.json`.

R30 pasa a PASS: el SQL corrió dentro de un proyecto de Supabase. Una captura del SQL Editor en el navegador es opcional para Miguel si el instructor la pide.
