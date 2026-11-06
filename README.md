# EduTrack Data Audit

Auditoría de la tabla `enrollments` de EduTrack. El trabajo pedido son doce consultas SQL, en orden, y un informe con los resultados de esa ejecución.

Las tablas `students` y `courses` se cargan como contexto y no se modifican.

## Estructura

| Archivo | Para qué |
| --- | --- |
| `queries.sql` | Q1–Q12. Es el archivo que se ejecuta. |
| `analysis_report.md` | Resultados de esa ejecución, para leer sin abrir un cliente SQL. |
| `edutrack.sql` | Carga oficial. Crea y llena las tres tablas. |
| `scripts/recreate_and_run.sh` | Borra la base local, la vuelve a crear y corre todo el recorrido. |
| `evidence/psql/` | Salida de la última ejecución de ese script. |

`edutrack.sql` es el asset del enunciado, sin cambios. SHA-256: `faebf83f72bbf95d7ef55aad78f36fc9168891c36e8994eeb4a65629086e3387`.

## Cómo ejecutarlo en PostgreSQL local

Hace falta PostgreSQL con `psql`, `createdb` y `dropdb`. El script usa el usuario actual si puede conectar, y si no, entra con `sudo -u postgres`.

```bash
./scripts/recreate_and_run.sh
```

Eso hace, en este orden:

1. Comprueba que `queries.sql` va de Q1 a Q12, que Q9 queda después de las correcciones y que no escribe en `students` ni en `courses`.
2. Comprueba el SHA-256 de `edutrack.sql`.
3. Recrea la base `edutrack`.
4. Carga `edutrack.sql` y revisa que las tres tablas tengan filas.
5. Guarda una foto de los agregados y de los filtros de lectura antes de corregir.
6. Ejecuta `queries.sql` una sola vez.
7. Guarda la foto de después, repite esos filtros y corre las aserciones de cierre.

La base por defecto se llama `edutrack`. Otro nombre: `EDUTRACK_DB=edutrack_check ./scripts/recreate_and_run.sh`.

La salida queda en `evidence/psql/`. Si algo no cuadra, el script termina con error.

## Decisiones

- Q1–Q5 leen la tabla recién importada. Q6 inserta la fila que el propio `edutrack.sql` describe en el comentario `MISSING RECORD` (`id = 18`). Q7 y Q8 corrigen, cada uno con un `SELECT` previo y el mismo `WHERE`. Q9–Q12 se calculan sobre lo que queda.
- Q4 ordena inscripciones con `passed = false` y se queda con cinco. El ranking es por inscripción: una persona con dos cursos sin aprobar puede aparecer dos veces.
- Q10 publica el `AVG(completion_percentage)` que devuelve PostgreSQL, con todos los decimales.
- El `INSERT` fija `id = 18`, como pide el comentario de la carga. No hace falta mover la secuencia: el `id` va explícito.
- `queries.sql` no usa metacomandos de `psql`. Esas órdenes (`\dt`) viven solo en el script de reproducción.

## Repetir la misma corrida en Supabase

En esta entrega las consultas se ejecutaron en PostgreSQL 16 local. El SQL no usa sintaxis exclusiva de esa versión. Para contrastarlo en el SQL Editor de Supabase:

1. Abrir el proyecto de Supabase y entrar en **SQL Editor**.
2. Pegar el contenido completo de `edutrack.sql` y ejecutarlo.
3. En una consulta nueva, ejecutar `SELECT * FROM enrollments LIMIT 5;` y comprobar que devuelve filas.
4. Pegar el contenido completo de `queries.sql` y ejecutarlo de arriba abajo, una sola vez.
5. Contrastar cada bloque de resultados con la sección del mismo número en `analysis_report.md`.
6. No lanzar `queries.sql` una segunda vez sobre la misma base: el `id = 18` ya existiría. Para repetir, volver a ejecutar `edutrack.sql` (hace `DROP` de las tres tablas) y después `queries.sql`.
7. No ejecutar sentencias que escriban en `students` o `courses`.

El editor de Supabase no guarda estos archivos. La copia que vale es la de este repositorio.
