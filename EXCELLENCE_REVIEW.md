# Revisión de excelencia — EduTrack Data Audit

Commit: `e446d9883294325009f58099e34a37c738a8322c`

Los extras están por encima de la rúbrica. No cambian el orden Q1–Q12 ni los valores que pide el comentario de `edutrack.sql`. No reparan R31.

## Recuento

Estado: **BLOCKED_INTEGRIDAD_MIGUEL**

Criterios obligatorios: **29/31 PASS**, **1 FAIL** (R31), **1 BLOCKED** (R30).

R31 cita `OFFICIAL_README.md`, línea 116: "Do not use AI tools to generate your SQL queries. Write each one yourself." Las consultas las escribió un agente de IA y la decisión (escribirlas Miguel, declarar el uso de IA o no entregar) es de Miguel.

E01 y E02 siguen implementados. Esta corrección no modifica `queries.sql` ni `analysis_report.md`.

## E01 — Informe con tablas y antes/después

Decisión: **IMPLEMENT**.

Qué se ve al leer `analysis_report.md`:

- Cada consulta tiene `Resultado:` y una tabla con las filas que devolvió PostgreSQL.
- Q9 y Q12 conservan además la lista con viñetas del ejemplo del enunciado.
- La sección «Antes y después de las correcciones (Q6–Q8)» compara conteos, ingresos, promedios y el único curso con más de 3 inscripciones.
- Esa sección también repite los filtros de Q1, Q2, Q4 y Q5 al final, para que se vea el efecto sin reescribir el resultado oficial de cada consulta.

Cifras que solo se entienden comparando los dos momentos, y que salen de las fotos guardadas:

- Programming sigue en 7 inscripciones (sale James Miller y entra Lucia Fernandes) y el ingreso de la categoría pasa de 389.93 a 409.93.
- Design baja de 5 a 4 y de 209.95 a 169.96. En el ranking de ingreso pasa del segundo al tercer puesto.
- El promedio de Advanced Python baja de 67.5 a 45 porque el alta llega con avance 0.
- El promedio de Intro to Python sube de 70 a 80 porque el borrado se lleva la fila de James Miller, que está al 30.
- El ingreso total de las cuatro categorías pasa de 839.83 a 819.84. La diferencia, −19.99, es 69.99 − 49.99 − 39.99.

Evidencia: `analysis_report.md:194`. Salidas `evidence/psql/03_snapshot_before.txt`, `03b_filters_before.txt`, `04_queries.txt`, `05_snapshot_after.txt`, `05b_filters_after.txt`.

## E02 — Recorrido reproducible

Decisión: **IMPLEMENT**.

`queries.sql` numera Q1–Q12, comenta cada bloque y pone un `SELECT` con el mismo filtro antes del `UPDATE` y antes del `DELETE`. El `DELETE` devuelve también avance y cuota, así el informe no tiene que ir a buscar esas cifras a otro sitio.

`scripts/recreate_and_run.sh`:

1. Rechaza metacomandos de `psql` dentro de `queries.sql`, un desorden Q1–Q12, o una escritura en `students` o `courses`.
2. Comprueba el SHA-256 oficial de `edutrack.sql`.
3. Borra y crea la base, carga el dump y guarda la salida.
4. Fotografía agregados y filtros antes y después.
5. Ejecuta `queries.sql` una vez.
6. Corre `scripts/assert_after.sql`, que falla con `EXCEPTION` si la fila 18 no coincide con el comentario, si queda un instructor `NULL`, si queda un `@test.com` en `enrollments`, o si cambian los conteos de `students` y `courses`.
7. Compara el hash de `students` y de `courses` antes y después.

La corrida comprometida en el commit termina con `assert=pass` en `evidence/psql/07_run_stamp.txt`.

## Tercera idea, no implementada

Una restricción `CHECK` para impedir nuevas inscripciones `@test.com`, o una vista de reporte por categoría.

Decisión: **DEFER**.

El enunciado pide un `DELETE` de las inscripciones de prueba que ya están, y pide no modificar `students` ni `courses`. Añadir una restricción cambia la definición de `enrollments` más allá de esa corrección. La siguiente fase del esquema, si la hay, partiría de una tabla distinta a la del enunciado. El script y el informe ya dejan medido el efecto del borrado.

## Revisión después de implementar

Se volvió a lanzar `./scripts/recreate_and_run.sh` después de ampliar las columnas del `SELECT` y del `DELETE` de Q8. Las aserciones pasaron. Las tablas del informe coinciden con `evidence/psql/04_queries.txt` de esa corrida (`2026-11-06T09:12:56+00:00`).
