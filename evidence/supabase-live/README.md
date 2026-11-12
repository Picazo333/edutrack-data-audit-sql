# 020: corrida en Supabase (proyecto 4geeks-cohorte, ref atraotgdztnrqystnujh)

Fecha: 2026-11-06 11:58:33 CST. Postgres 17.11 de Supabase, ejecutado con el conector oficial (apply_migration y execute_sql). Autorizado por Miguel a las 11:52 CST.

- Migración `edutrack_020_load_official_v2`: `edutrack_v2.sql` oficial (sha256 `091f6fa2…7cb0`) cargado en el schema `edutrack_020`. Copia exacta: `00-migration-applied.sql`.
- Importación: tablas courses, enrollments y students.
- `queries.sql` Q1–Q10 (con SET datestyle ISO, YMD): filas 16, 6, 4, 1, 1, 7, 4, 4, 0 y 0. Coincide exactamente con `expected_rows` de `scripts/recreate_and_run_v2.sh`. Q9 y Q10 dan 0 huérfanos.
- `scripts/v2/assert_v2.sql` devuelve `assert_v2_020=pass`.
- Salida completa: `01-results-Q1-Q10.json`.

R04 y R25 pasan a PASS: se usó un proyecto de Supabase y el SQL corrió ahí sin errores, con los resultados esperados. R30 (entrega al instructor) sigue siendo de Miguel.
