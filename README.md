# EduTrack Data Audit

Hay dos auditorías en este repositorio.

La de tablas relacionadas está en la raíz: `queries.sql`, `analysis_report.md`, `diagram.png` y `edutrack_v2.sql`. Cómo correrla está en «Esquema normalizado».

La auditoría de la tabla plana `enrollments` está en `019/`. El script y el criterio de esa corrida siguen igual; solo cambió la ruta de sus dos archivos para dejar la raíz a la auditoría nueva.

## Esquema normalizado

`students`, `courses` y `enrollments` son tres tablas unidas por claves foráneas. Las diez consultas usan al menos un JOIN. Ninguna usa subconsultas y ninguna escribe.

| Archivo | Para qué |
| --- | --- |
| `queries.sql` | Q1–Q10. Es el archivo que se ejecuta. |
| `analysis_report.md` | Resultados de esa ejecución. |
| `diagram.png` | Diagrama exportado desde diagram.4geeks.com. |
| `diagram.4geeks.json` | Carga de ese diagrama. |
| `diagram.dbml` | Los mismos tres objetos, con los tipos SQL del asset. |
| `edutrack_v2.sql` | Carga oficial. Crea y llena las tres tablas. |
| `scripts/recreate_and_run_v2.sh` | Borra la base `edutrack_v2`, la vuelve a crear y corre todo el recorrido. |
| `scripts/v2/integrity.sql` | Suite de integridad. Tras la importación se esperan 0 huérfanos. |
| `evidence/psql-v2/` | Salida de la última ejecución de ese script. |
| `evidence/diagram/` | Registro de la exportación del diagrama. |

`edutrack_v2.sql` es el asset del enunciado, sin cambios. SHA-256: `091f6fa2948d0847cfe06937b2d24572a0afa292fbd19412764c220d39e17cb0`.

### Cómo ejecutarlo en PostgreSQL local

Hace falta PostgreSQL con `psql`, `createdb` y `dropdb`. El script usa el usuario actual si puede conectar, y si no, entra con `sudo -u postgres`. No toca la base `edutrack` de la auditoría plana.

```bash
./scripts/recreate_and_run_v2.sh
```

Eso hace, en este orden:

1. Comprueba que `019/queries.sql` y `019/analysis_report.md` siguen siendo los archivos de la auditoría plana.
2. Comprueba que `queries.sql` va de Q1 a Q10, que cada consulta tiene un JOIN, que no hay subconsultas y que Q7 suma `courses.monthly_fee`.
3. Comprueba el SHA-256 de `edutrack_v2.sql`.
4. Recrea la base `edutrack_v2`.
5. Carga el asset y ejecuta `SELECT * FROM enrollments LIMIT 5`, `SELECT * FROM students LIMIT 5` y `SELECT * FROM courses LIMIT 5`.
6. Ejecuta `queries.sql` y la suite de integridad.
7. Contrasta los resultados con `analysis_report.md` y comprueba que `diagram.png` es un PNG.

La base por defecto se llama `edutrack_v2`. Otro nombre: `EDUTRACK_V2_DB=edutrack_v2_check ./scripts/recreate_and_run_v2.sh`.

La salida queda en `evidence/psql-v2/`. Si algo no cuadra, el script termina con error.

### Decisiones

- Q2 devuelve una fila por inscripción aprobada. Quien aprobó dos cursos sale dos veces, con el título de cada curso.
- Q3 publica el `AVG(completion_percentage)` que devuelve PostgreSQL, con todos los decimales.
- Q6 usa `GROUP BY` y `HAVING COUNT(...) > 1`.
- Q7 suma el precio actual, `courses.monthly_fee`, una vez por inscripción. No suma `monthly_fee_paid`. En esta carga las dos cifras coinciden fila a fila; la consulta no depende de eso.
- Q8 cuenta estudiantes distintos. Una persona en dos cursos del mismo instructor cuenta una vez.
- Q9 y Q10 devuelven 0 filas. El script lo exige.
- El diagrama no dibuja una relación 1:1: el esquema no tiene ninguna. `students` y `courses` quedan en n:m a través de `enrollments`. Cada clave foránea es 1:n.
- `queries.sql` no usa metacomandos de `psql`. `\dt` vive solo en el script de reproducción.

### Repetir la misma corrida en Supabase

En esta entrega las consultas se ejecutaron en PostgreSQL 16 local. El SQL no usa sintaxis exclusiva de esa versión. Para contrastarlo en el SQL Editor de Supabase, con un proyecto que ya exista:

1. Abrir el proyecto y entrar en **SQL Editor**.
2. Pegar el contenido completo de `edutrack_v2.sql` y ejecutarlo. El archivo hace `DROP` de las tres tablas y las vuelve a crear.
3. En una consulta nueva, ejecutar estas tres sentencias y comprobar que cada una devuelve filas:

```sql
SELECT * FROM enrollments LIMIT 5;
SELECT * FROM students LIMIT 5;
SELECT * FROM courses LIMIT 5;
```

4. Pegar el contenido completo de `queries.sql` y ejecutarlo de arriba abajo.
5. Contrastar cada bloque con la sección del mismo número en `analysis_report.md`.
6. `queries.sql` solo lee. Se puede volver a lanzar sobre la misma base.

El editor de Supabase no guarda estos archivos. La copia que vale es la de este repositorio. Esta sesión no abrió Supabase ni creó un proyecto.

### Volver a sacar el diagrama

1. Abrir [diagram.4geeks.com](https://diagram.4geeks.com). No hace falta cuenta.
2. Elegir **Load from JSON** y abrir `diagram.4geeks.json`.
3. Comprobar las tres tablas, `id` como clave primaria, y `student_id` / `course_id` como claves foráneas hacia `students.id` y `courses.id`.
4. **Export as PNG** y sustituir `diagram.png` en la raíz si se quiere una captura de esa sesión.

La imagen que hay ahora salió de ese sitio con `scripts/export_diagram.cjs` (Chrome y `puppeteer-core`). El registro está en `evidence/diagram/export_log.txt`.

## Auditoría de la tabla plana

Auditoría de la tabla `enrollments` de EduTrack. El trabajo pedido son doce consultas SQL, en orden, y un informe con los resultados de esa ejecución.

Las tablas `students` y `courses` se cargan como contexto y no se modifican.

### Estructura

| Archivo | Para qué |
| --- | --- |
| `019/queries.sql` | Q1–Q12. Es el archivo que ejecuta `scripts/recreate_and_run.sh`. |
| `019/analysis_report.md` | Resultados de esa ejecución, para leer sin abrir un cliente SQL. |
| `edutrack.sql` | Carga oficial. Crea y llena las tres tablas. |
| `scripts/recreate_and_run.sh` | Borra la base local, la vuelve a crear y corre todo el recorrido. |
| `evidence/psql/` | Salida de la última ejecución de ese script. |

`edutrack.sql` es el asset del enunciado, sin cambios. SHA-256: `faebf83f72bbf95d7ef55aad78f36fc9168891c36e8994eeb4a65629086e3387`.

### Cómo ejecutarlo en PostgreSQL local

Hace falta PostgreSQL con `psql`, `createdb` y `dropdb`. El script usa el usuario actual si puede conectar, y si no, entra con `sudo -u postgres`.

```bash
./scripts/recreate_and_run.sh
```

Eso hace, en este orden:

1. Comprueba que `019/queries.sql` va de Q1 a Q12, que Q9 queda después de las correcciones y que no escribe en `students` ni en `courses`.
2. Comprueba el SHA-256 de `edutrack.sql`.
3. Recrea la base `edutrack`.
4. Carga `edutrack.sql` y revisa que las tres tablas tengan filas.
5. Guarda una foto de los agregados y de los filtros de lectura antes de corregir.
6. Ejecuta `019/queries.sql` una sola vez.
7. Guarda la foto de después, repite esos filtros y corre las aserciones de cierre.

La base por defecto se llama `edutrack`. Otro nombre: `EDUTRACK_DB=edutrack_check ./scripts/recreate_and_run.sh`.

La salida queda en `evidence/psql/`. Si algo no cuadra, el script termina con error.

### Decisiones

- Q1–Q5 leen la tabla recién importada. Q6 inserta la fila que el propio `edutrack.sql` describe en el comentario `MISSING RECORD` (`id = 18`). Q7 y Q8 corrigen, cada uno con un `SELECT` previo y el mismo `WHERE`. Q9–Q12 se calculan sobre lo que queda.
- Q4 ordena inscripciones con `passed = false` y se queda con cinco. El ranking es por inscripción: una persona con dos cursos sin aprobar puede aparecer dos veces.
- Q10 publica el `AVG(completion_percentage)` que devuelve PostgreSQL, con todos los decimales.
- El `INSERT` fija `id = 18`, como pide el comentario de la carga. No hace falta mover la secuencia: el `id` va explícito.
- `019/queries.sql` no usa metacomandos de `psql`. Esas órdenes (`\dt`) viven solo en el script de reproducción.

### Repetir la misma corrida en Supabase

En esta entrega las consultas se ejecutaron en PostgreSQL 16 local. El SQL no usa sintaxis exclusiva de esa versión. Para contrastarlo en el SQL Editor de Supabase:

1. Abrir el proyecto de Supabase y entrar en **SQL Editor**.
2. Pegar el contenido completo de `edutrack.sql` y ejecutarlo.
3. En una consulta nueva, ejecutar `SELECT * FROM enrollments LIMIT 5;` y comprobar que devuelve filas.
4. Pegar el contenido completo de `019/queries.sql` y ejecutarlo de arriba abajo, una sola vez.
5. Contrastar cada bloque de resultados con la sección del mismo número en `019/analysis_report.md`.
6. No lanzar `019/queries.sql` una segunda vez sobre la misma base: el `id = 18` ya existiría. Para repetir, volver a ejecutar `edutrack.sql` (hace `DROP` de las tres tablas) y después `019/queries.sql`.
7. No ejecutar sentencias que escriban en `students` o `courses`.

El editor de Supabase no guarda estos archivos. La copia que vale es la de este repositorio.
