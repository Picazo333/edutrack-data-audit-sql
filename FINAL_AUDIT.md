# Auditoría final

Estado: **PENDIENTE_REVISION_ORQUESTADOR**. No se hizo merge del pull request. No se envió nada al LMS.

## Resultado

**28/30 PASS. 0 FAIL. 0 BLOCKED_HITL. 1 HITL_MIGUEL. 1 HITL_ENVIO_MIGUEL.**

28 + 0 + 0 + 1 + 1 = 30.

| Estado | N | IDs |
| --- | --- | --- |
| PASS | 28 | R01, R02, R03, R04, R05, R06, R07, R08, R09, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, R20, R21, R22, R23, R24, R25, R26, R27, R29 |
| FAIL | 0 | — |
| BLOCKED_HITL | 0 | — |
| HITL_MIGUEL | 1 | R28 |
| HITL_ENVIO_MIGUEL | 1 | R30 |

R04 y R25 están **PASS**. Evidencia en `evidence/supabase-live/`: migración aplicada y lecturas Q1–Q10 en el proyecto Supabase 4geeks-cohorte, 12 nov 2026. La migración aplicada está en `evidence/supabase-live/00-migration-applied.sql` y las lecturas en `evidence/supabase-live/01-results-Q1-Q10.json`. El README de esa carpeta fecha la ejecución el 2026-11-06 11:58 CST, en Postgres 17.11 del proyecto 4geeks-cohorte (ref `atraotgdztnrqystnujh`).

R28 está HITL_MIGUEL. declaración de autoría/uso de herramientas al entregar: decisión de Miguel.

R30 está HITL_ENVIO_MIGUEL. El envío al instructor queda fuera de esta corrida.

### Pasos para repetirla en Supabase

1. Abrir el proyecto de Supabase que ya tenga Miguel y entrar en **SQL Editor**.
2. Pegar el contenido completo de `edutrack_v2.sql` y ejecutarlo.
3. En una consulta nueva, ejecutar y comprobar que cada sentencia devuelve filas:

```sql
SELECT * FROM enrollments LIMIT 5;
SELECT * FROM students LIMIT 5;
SELECT * FROM courses LIMIT 5;
```

4. Pegar `queries.sql` y ejecutarlo de arriba abajo.
5. Contrastar cada bloque con la sección del mismo número en `analysis_report.md`. La corrida local de referencia es `2026-11-06T14:52:20+00:00` (PostgreSQL 16.15, `assert=pass`).
6. `queries.sql` solo lee. Para volver al estado de la carga, ejecutar otra vez `edutrack_v2.sql`.

Los mismos pasos están en `README.md`.

## Qué se revisó al cierre

- Merge normal de `cursor/edutrack-data-audit-f76c` en `fcb2dd3456f69cb498c6922ce0af590c1730c2af`. Sin rebase y sin force-push. Los documentos de esa rama quedaron byte a byte en `019/`.
- `./scripts/recreate_and_run_v2.sh` terminó en 0 el `2026-11-06T14:52:20+00:00`. Q1–Q10 están en `evidence/psql-v2/03_queries.txt`. Huérfanos: 0 y 0. `assert=pass`.
- SHA-256 de `edutrack_v2.sql`: `091f6fa2948d0847cfe06937b2d24572a0afa292fbd19412764c220d39e17cb0`.
- SHA-256 de `019/queries.sql` y de `019/analysis_report.md` sigue siendo el de `019/SHA256SUMS`.
- `diagram.png` es la exportación PNG de diagram.4geeks.com. `diagram.dbml` no puntúa ese criterio.

## Orden de merge

1. Primero el PR #1 hacia `main`.
2. Después el PR #2. No mezclar este PR antes que el #1.

## Fuera de alcance

El enunciado dice que el borrado en cascada se ve en la teoría y no se pide en las consultas. No hay prueba de `ON DELETE CASCADE`.
