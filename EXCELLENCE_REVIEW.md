# Revisión de excelencia

Los extras no cambian el enunciado. Los dos pedidos en el lanzamiento están hechos. Un tercero, el workflow, también.

## Visible — IMPLEMENT

La sección «Integridad referencial» va delante de las consultas, con el cero en una cita y en una tabla de dos filas. Q9 y Q10 repiten el detalle. `diagram.png` está embebido en el informe, no solo suelto en la raíz.

Evidencia: `analysis_report.md` líneas 24-42. La imagen es la exportación de diagram.4geeks.com (`evidence/diagram/export_log.txt` y `evidence/diagram/tool_screen.png`).

## Técnico — IMPLEMENT

`scripts/v2/integrity.sql` documenta el resultado esperado tras importar el asset sin más escrituras:

- 0 huérfanos por `student_id`
- 0 huérfanos por `course_id`
- 2 claves foráneas en `enrollments`
- 0 filas donde `monthly_fee_paid` difiere de `courses.monthly_fee`
- 0 pares repetidos `(student_id, course_id)`
- 1 estudiante sin inscripción y 1 curso sin inscripción

`scripts/v2/assert_v2.sql` corta la corrida si el cero de huérfanos, los ingresos o los promedios no cuadran. En la corrida de referencia las dos cuentas de huérfanos salieron 0 y el sello dice `assert=pass`.

Evidencia: `evidence/psql-v2/04_integrity.txt` (I2 e I3 imprimen 0; I4 e I5 imprimen `(0 rows)`) y `evidence/psql-v2/05_assert.txt`.

## Tercero — IMPLEMENT

`.github/workflows/sql.yml` lanza la auditoría plana y después la normalizada, en PostgreSQL del runner. En esta sesión los dos scripts terminaron en local con código 0. La ejecución de GitHub Actions no se esperó.

La corrida plana se usó solo para comprobar que el cambio de ruta no la rompe. La evidencia ya commiteada de `evidence/psql/` no se sustituyó: el único archivo que difería era el sello de hora, y se restauró.

## Rechazado

- Un doble de Supabase marcado como PASS. El enunciado pide el editor real. R04 y R25 siguen BLOCKED.
- Un PNG de Mermaid o de Graphviz presentado como diagram.4geeks.com. No hizo falta: el sitio exportó sin cuenta. `diagram.dbml` se queda como texto de apoyo y no puntúa R05 ni R06.
