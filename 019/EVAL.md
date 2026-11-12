# EVAL — EduTrack Data Audit

Pasada: `2026-11-06T14:47:58+00:00`. Motor: PostgreSQL 16.15. Comando: `./scripts/recreate_and_run.sh`. Resultado: `assert=pass` en `evidence/psql/07_run_stamp.txt`.

La base se recreó desde `edutrack.sql` (sha256 `faebf83f72bbf95d7ef55aad78f36fc9168891c36e8994eeb4a65629086e3387`). `queries.sql` (sha256 `3af333ff5e4bef38e30389c17e2feb1e8a03308b3cccb10d9a699c7d6ccbe6e0`) se ejecutó una vez, en orden Q1–Q12. La salida completa está en `evidence/psql/04_queries.txt`.

## Consultas

| ID | Qué devolvió esta corrida | Estado |
| --- | --- | --- |
| Q1 | 5 filas de Intro to Python (nombre, email, avance) | PASS |
| Q2 | 4 filas con avance menor que 10 | PASS |
| Q3 | 2 filas con instructor NULL | PASS |
| Q4 | 5 filas con `passed = false`, mayor avance primero | PASS |
| Q5 | 9 filas desde 2024-07-01, fecha descendente | PASS |
| Q6 | `INSERT 0 1`, id 18, valores del comentario de la carga | PASS |
| Q7 | `UPDATE 2`, solo NULL → `Pending assignment` | PASS |
| Q8 | `DELETE 2`, solo `@test.com` | PASS |
| Q9 | Programming 7, Design 4, Data 3, Marketing 2 | PASS |
| Q10 | 6 promedios, de UI/UX en 0 a Intro to Python en 80 | PASS |
| Q11 | `HAVING`: solo Intro to Python, 4 inscripciones | PASS |
| Q12 | Programming 409.93, Data 179.97, Design 169.96, Marketing 59.98 | PASS |

`students` y `courses` conservan el hash de antes de las correcciones. No hubo reparación en esta pasada: las aserciones cerraron a la primera.

## Recuento

Obligatorios R01–R29, R30 y R31: 31.

| Estado | N | IDs |
| --- | --- | --- |
| PASS | 30 | R01–R30 |
| FAIL | 0 | — |
| BLOCKED_HITL | 0 | — |
| HITL_MIGUEL | 1 | R31 |

30 + 0 + 0 + 1 = 31.

R30 está **PASS**. Evidencia en `evidence/supabase-live/`: migración aplicada y lecturas Q1–Q12 en el proyecto Supabase 4geeks-cohorte, 12 nov 2026. En esta rama las lecturas siguen en `evidence/supabase-live/01-results-Q1-Q12.json`; la migración 019 está en el commit `6f09d990a4b2d10821e463c4a3e2501d1720c4f2` de `cursor/edutrack-data-audit-f76c`, porque aquí `evidence/supabase-live/00-migration-applied.sql` es la migración 020. Esa corrida está fechada el 2026-11-06 11:58 CST.

## Pendientes

- R31, HITL_MIGUEL. Declaración de autoría/uso de herramientas al entregar: decisión de Miguel.
