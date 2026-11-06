# Auditoría final — EduTrack Data Audit

Estado: **BLOCKED_INTEGRIDAD_MIGUEL**

| Dato | Valor |
| --- | --- |
| Repositorio | https://github.com/Picazo333/edutrack-data-audit-sql |
| Rama | `cursor/edutrack-data-audit-f76c` |
| Commit | `e446d9883294325009f58099e34a37c738a8322c` |
| Pull request | https://github.com/Picazo333/edutrack-data-audit-sql/pull/1 |
| Base | `main` |
| Merge | No realizado |
| LMS | No enviado |

## Resultado

**29/31 PASS. 1 FAIL. 1 BLOCKED.**

R31 está FAIL. `OFFICIAL_README.md`, línea 116, dice: "Do not use AI tools to generate your SQL queries. Write each one yourself." Las consultas las escribió un agente de IA y la decisión (escribirlas Miguel, declarar el uso de IA o no entregar) es de Miguel. `queries.sql` y `analysis_report.md` no se tocan en esta corrección: sus SHA-256 siguen siendo `3af333ff5e4bef38e30389c17e2feb1e8a03308b3cccb10d9a699c7d6ccbe6e0` y `e36f3f5f7d7bc58b3c2727b170729379fdc678c11445b7433a994fca52290027`.

R30 está BLOCKED. El enunciado pide un proyecto de Supabase y el SQL Editor. No hay cuenta ni credenciales, y no se creó ninguna. La misma auditoría se ejecutó en PostgreSQL 16.15 local, que es el dialecto de Supabase. Eso sostiene R21 y no convierte R30 en PASS.

### Pasos para repetirla en Supabase

1. Abrir el proyecto de Supabase que ya tenga Miguel y entrar en **SQL Editor**.
2. Pegar el contenido completo de `edutrack.sql` y ejecutarlo.
3. En una consulta nueva, ejecutar `SELECT * FROM enrollments LIMIT 5;` y comprobar que devuelve filas.
4. Pegar el contenido completo de `queries.sql` y ejecutarlo de arriba abajo, una sola vez.
5. Contrastar cada bloque con la sección del mismo número en `analysis_report.md`. La corrida local de referencia es `2026-11-06T09:12:56+00:00` (PostgreSQL 16.15, `assert=pass`).
6. Para repetir, volver a ejecutar `edutrack.sql` (hace `DROP` de las tres tablas) y después `queries.sql`. Una segunda pasada de `queries.sql` sobre la misma base choca con el `id = 18`.
7. No ejecutar sentencias que escriban en `students` o `courses`.

Los mismos pasos están en `README.md`, sección «Repetir la misma corrida en Supabase».

## Qué se revisó al cierre

- `queries.sql` va de Q1 a Q12. Q9 está después del `DELETE`. Hay un `SELECT` con el mismo `WHERE` antes del `UPDATE` y antes del `DELETE`.
- La fila 18 usa los valores del comentario `MISSING RECORD` de `edutrack.sql` (líneas 109–127). El SHA-256 del archivo es `faebf83f72bbf95d7ef55aad78f36fc9168891c36e8994eeb4a65629086e3387`.
- La corrida guardada en `evidence/psql/` termina con `assert=pass`. Quedan 16 inscripciones, 0 instructores `NULL`, 0 correos `@test.com` en `enrollments`, y los hashes de `students` y `courses` no cambian.
- El informe tiene las doce secciones rellenas y la comparación de antes y después. Las cifras citadas están en `04_queries.txt` o en las fotos `03_*` y `05_*`.
- No hay UI. El lockup no aplica. `DESIGN-QA.md` lo deja escrito. No hay capturas que inventar.
- No se añadió una restricción nueva ni una vista. Esa idea queda diferida en `EXCELLENCE_REVIEW.md` porque el enunciado pide corregir filas, no cambiar el esquema.

## Límites que quedan a la vista

- Q4 es un ranking de inscripciones. Emily Watson sale dos veces. El informe lo dice para que el equipo no lo lea como cinco personas distintas.
- Q10 muestra el `AVG` con todos los decimales que devuelve PostgreSQL. Data Analysis with SQL queda en `47.6666666666666667`.
- Q2 oficial tiene 4 filas. Después del alta hay una quinta por debajo del 10 % (Lucia Fernandes, Advanced Python, avance 0). Esa quinta fila está en la sección de antes y después, no dentro del resultado de Q2.
- El `id = 18` va explícito. La secuencia de `SERIAL` no se mueve. No hace falta para esta auditoría, y un `INSERT` posterior sin `id` podría chocar. Queda fuera del enunciado.
- `SET datestyle TO ISO, YMD` al principio de `queries.sql` solo afecta al formato de las fechas en la sesión.

## Cierre

La corrida local de PostgreSQL sigue contrastada con la salida de `psql`. R31 queda en FAIL y el estado de esta corrección es BLOCKED_INTEGRIDAD_MIGUEL. Sigue bloqueada la corrida en el SQL Editor de Supabase (R30). No se hace merge y no se envía nada al LMS.
