# Auditoría final

Estado: **PENDIENTE_REVISION_ORQUESTADOR**. No es READY_TO_SUBMIT. No se hizo merge. No se envió nada al LMS.

## Resultado

30 criterios obligatorios: **26 PASS**, **3 BLOCKED**, **1 FAIL**.

| Estado | IDs |
| --- | --- |
| PASS | R01, R02, R03, R05, R06, R07, R08, R09, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, R20, R21, R22, R23, R24, R26, R27, R29 |
| BLOCKED | R04, R25, R30 |
| FAIL | R28 |

R04 y R25 piden Supabase. No hay proyecto abierto en esta sesión. Los pasos para repetirlos están en `RUBRIC_JUSTIFICATION.md`. R30 es la entrega al instructor: queda para Miguel.

R28 falla porque las consultas las escribió el agente de esta sesión. El enunciado prohíbe generarlas con IA. Ejecutarlas y dejar el resultado real no convierte ese criterio en PASS.

## Qué se revisó al cierre

- `./scripts/recreate_and_run_v2.sh` terminó en 0 el `2026-11-06T09:32:23+00:00`.
- `./scripts/recreate_and_run.sh` terminó en 0 después del cambio de ruta. Los resultados coinciden con la evidencia ya guardada de la auditoría plana; solo cambiaba la hora del sello, y ese directorio se restauró.
- `diagram.png` es un PNG de 870×770 escrito por diagram.4geeks.com. La captura del sitio está en `evidence/diagram/tool_screen.png`.
- SHA-256 de `edutrack_v2.sql`: `091f6fa2948d0847cfe06937b2d24572a0afa292fbd19412764c220d39e17cb0`.
- SHA-256 de `019/queries.sql` y de `019/analysis_report.md` coincide con `019/SHA256SUMS`. El texto de esas dos piezas no se reescribió. Se movieron de la raíz para que `queries.sql` y `analysis_report.md` fueran los de esta auditoría, que es lo que pide el enunciado.

## Orden de merge

1. Primero el PR #1 (`cursor/edutrack-data-audit-f76c`) hacia `main`.
2. Después este PR, cuya base es `cursor/edutrack-data-audit-f76c`. El diff de este PR es el de la auditoría normalizada.

No mezclar este PR hacia `main` antes que el #1: la base dejaría de ser la rama del 019 y el diff mezclaría las dos entregas.

## Fuera de alcance

El enunciado dice que el borrado en cascada se ve en la teoría y no se pide en las consultas. No hay prueba de `ON DELETE CASCADE`.
