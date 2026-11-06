# EVAL — EduTrack, tablas relacionadas

Pasada: `2026-11-06T14:52:20+00:00`. Motor: PostgreSQL 16.15. Comando: `./scripts/recreate_and_run_v2.sh`. Resultado: `assert=pass` en `evidence/psql-v2/06_run_stamp.txt`.

La base `edutrack_v2` se recreó desde `edutrack_v2.sql` (sha256 `091f6fa2948d0847cfe06937b2d24572a0afa292fbd19412764c220d39e17cb0`). `queries.sql` (sha256 `797bde8f286efcfb27daafae9a6bc9a6d8ed6ab453aa962c66a9f609952b0108`) se ejecutó una vez, Q1–Q10. La salida está en `evidence/psql-v2/03_queries.txt`. Las aserciones cerraron a la primera en esta pasada.

## Consultas

| ID | Qué devolvió esta corrida | Estado |
| --- | --- | --- |
| Q1 | 16 filas: nombre, título y porcentaje. Sin Giulia Romano y sin Email Campaigns | PASS |
| Q2 | 6 filas aprobadas, con nombre, email y título | PASS |
| Q3 | 4 promedios, de Marta López (66.1428571428571429) a Pending assignment (0) | PASS |
| Q4 | 1 fila: Giulia Romano, sin inscripción | PASS |
| Q5 | 1 fila: Email Campaigns, sin inscripción | PASS |
| Q6 | 7 estudiantes con más de un curso (`GROUP BY` + `HAVING`) | PASS |
| Q7 | Programming 409.93, Data 179.97, Design 169.96, Marketing 59.98, con `courses.monthly_fee` | PASS |
| Q8 | Marta López 6, Carlos Vega 3, Lucia Prades 2, Pending assignment 2 | PASS |
| Q9 | 0 filas huérfanas por `student_id` | PASS |
| Q10 | 0 filas huérfanas por `course_id` | PASS |

La suite `scripts/v2/integrity.sql` repite el cero de huérfanos. I2 e I3 imprimen 0. `evidence/psql-v2/05_assert.txt` dice `assert=pass`.

## Recuento

Obligatorios R01–R30: 30.

| Estado | N | IDs |
| --- | --- | --- |
| PASS | 26 | R01, R02, R03, R05, R06, R07, R08, R09, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, R20, R21, R22, R23, R24, R26, R27, R29 |
| FAIL | 0 | — |
| BLOCKED_HITL | 2 | R04, R25 |
| HITL_MIGUEL | 1 | R28 |
| HITL_ENVIO_MIGUEL | 1 | R30 |

26 + 0 + 2 + 1 + 1 = 30.

## Pendientes

- R04 y R25, BLOCKED_HITL. El enunciado pide Supabase. No hay sesión ni proyecto en esta corrida, y no se crea una cuenta. Los pasos están en `README.md`.
- R28, HITL_MIGUEL. declaración de autoría/uso de herramientas al entregar: decisión de Miguel.
- R30, HITL_ENVIO_MIGUEL. El envío al instructor no se hace en esta corrida.
