# Auditoría de datos de EduTrack

Revisión de la tabla `enrollments` antes del ciclo de reporte del Q3. Las tablas `students` y `courses` se usaron solo como contexto: su contenido queda igual que en la carga.

Corrida de referencia: PostgreSQL 16.15, 2026-11-06T09:12:56+00:00. Las tablas de Q1 a Q12 salen de `evidence/psql/04_queries.txt`. El antes y el después salen de `evidence/psql/03_snapshot_before.txt`, `evidence/psql/03b_filters_before.txt`, `evidence/psql/05_snapshot_after.txt` y `evidence/psql/05b_filters_after.txt`.

En la salida cruda de `psql`, `false` se imprime como `f` y un `NULL` se imprime como celda vacía. En este informe esas celdas se escriben `false` y `NULL`.

## Cómo está ordenado

Q1–Q5 leen las 17 inscripciones importadas. Q6–Q8 corrigen. Q9–Q12 agregan las 16 inscripciones que quedan. La última sección compara los dos momentos. El resultado oficial de cada consulta es el de su propia sección, en ese orden.

## Resumen

- La carga trae 17 inscripciones, 2 con instructor vacío y 2 de cuentas `@test.com`.
- Q2 marca 4 inscripciones por debajo del 10 % de avance. Dos de ellas son las mismas que llegaron sin instructor (UI/UX Fundamentals).
- Q6 añade la inscripción 18 de Lucia Fernandes en Advanced Python (2025-04-01, avance 0, cuota 69.99, instructor Carlos Vega).
- Q7 escribe `Pending assignment` en las 2 filas con instructor `NULL`.
- Q8 borra las inscripciones de `james.miller@test.com` y `alex.chen@test.com`. Esas dos personas siguen en `students`.
- Después de corregir quedan 16 inscripciones. Programming sigue en 7 (sale una de prueba y entra la de Lucia). Design baja de 5 a 4.
- El único curso con más de 3 inscripciones es Intro to Python: 5 antes del borrado y 4 después.
- Ingreso cobrado después de corregir: Programming 409.93, Data 179.97, Design 169.96, Marketing 59.98. El total de esas cuatro cifras es 819.84. Antes de corregir era 839.83.
- El promedio de avance más bajo es UI/UX Fundamentals (0). El más alto, después de quitar la cuenta de prueba, es Intro to Python (80).

## Q1 — Inscripciones en 'Intro to Python'

Resultado: 5

| student_name | student_email | completion_percentage |
| --- | --- | --- |
| Emily Watson | emily.watson@student.edutrack.com | 85 |
| James Miller | james.miller@test.com | 30 |
| Klaus Weber | klaus.weber@student.edutrack.com | 92 |
| Marco Rossi | marco.rossi@student.edutrack.com | 88 |
| Priya Sharma | priya.sharma@student.edutrack.com | 55 |

Cuatro alumnos reales y una cuenta de prueba. James Miller sigue en esta lista porque el borrado es Q8. El avance va de 30 a 92.

## Q2 — Avance menor que 10

Resultado: 4

| id | student_name | student_email | course_title | completion_percentage |
| --- | --- | --- | --- | --- |
| 10 | Yuki Nakamura | yuki.nakamura@student.edutrack.com | UI/UX Fundamentals | 0 |
| 11 | Pierre Dubois | pierre.dubois@student.edutrack.com | UI/UX Fundamentals | 0 |
| 6 | Lucia Fernandes | lucia.fernandes@student.edutrack.com | Digital Marketing 101 | 3 |
| 5 | Lucia Fernandes | lucia.fernandes@student.edutrack.com | Web Design Basics | 5 |

Son las candidatas a abandono en el momento de la consulta. Alex Chen queda fuera: su avance es 10 y el filtro es estrictamente menor que 10. Lucia Fernandes aparece dos veces, en dos cursos distintos.

## Q3 — Instructor NULL

Resultado: 2

| id | student_name | student_email | course_title | instructor |
| --- | --- | --- | --- | --- |
| 10 | Yuki Nakamura | yuki.nakamura@student.edutrack.com | UI/UX Fundamentals | NULL |
| 11 | Pierre Dubois | pierre.dubois@student.edutrack.com | UI/UX Fundamentals | NULL |

Las dos filas son de UI/UX Fundamentals y son también dos de los cuatro abandonos de Q2. El lote sin instructor y el avance en cero coinciden en el mismo curso.

## Q4 — Cinco no aprobadas con mayor avance

Resultado: 5

| student_name | student_email | course_title | completion_percentage | passed |
| --- | --- | --- | --- | --- |
| Emily Watson | emily.watson@student.edutrack.com | Web Design Basics | 60 | false |
| Priya Sharma | priya.sharma@student.edutrack.com | Intro to Python | 55 | false |
| Yuki Nakamura | yuki.nakamura@student.edutrack.com | Data Analysis with SQL | 45 | false |
| Emily Watson | emily.watson@student.edutrack.com | Advanced Python | 40 | false |
| James Miller | james.miller@test.com | Intro to Python | 30 | false |

El corte es por inscripción (`passed = false`, mayor `completion_percentage`, cinco filas). Emily Watson ocupa dos puestos, 60 y 40, porque tiene dos cursos sin aprobar. El quinto puesto es la cuenta de prueba de James Miller.

## Q5 — Inscripciones desde 2024-07-01

Resultado: 9

| id | student_name | student_email | course_title | enrollment_date |
| --- | --- | --- | --- | --- |
| 17 | Emily Watson | emily.watson@student.edutrack.com | Advanced Python | 2025-03-05 |
| 16 | Pierre Dubois | pierre.dubois@student.edutrack.com | Data Analysis with SQL | 2025-02-20 |
| 15 | Priya Sharma | priya.sharma@student.edutrack.com | Intro to Python | 2025-01-10 |
| 12 | Priya Sharma | priya.sharma@student.edutrack.com | Digital Marketing 101 | 2024-12-01 |
| 11 | Pierre Dubois | pierre.dubois@student.edutrack.com | UI/UX Fundamentals | 2024-11-05 |
| 10 | Yuki Nakamura | yuki.nakamura@student.edutrack.com | UI/UX Fundamentals | 2024-10-11 |
| 9 | Yuki Nakamura | yuki.nakamura@student.edutrack.com | Data Analysis with SQL | 2024-09-03 |
| 8 | Marco Rossi | marco.rossi@student.edutrack.com | Intro to Python | 2024-08-09 |
| 6 | Lucia Fernandes | lucia.fernandes@student.edutrack.com | Digital Marketing 101 | 2024-07-01 |

La fecha `2024-07-01` entra en el resultado. La inscripción de Alex Chen es del `2024-06-30` y queda fuera. La fila 18 todavía no existe en este punto, así que su fecha `2025-04-01` no aparece aquí.

## Q6 — Inscripción que faltaba

Resultado: 1 fila insertada, `id = 18`.

La comprobación anterior, con el mismo estudiante, curso y fecha, devolvió 0 filas. El `INSERT` usa los valores del comentario `MISSING RECORD` de `edutrack.sql`.

| id | student_id | student_name | student_email | course_id | course_title | category | enrollment_date | completion_percentage | passed | monthly_fee_paid | instructor |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 18 | 3 | Lucia Fernandes | lucia.fernandes@student.edutrack.com | 5 | Advanced Python | Programming | 2025-04-01 | 0 | false | 69.99 | Carlos Vega |

La etiqueta de comando fue `INSERT 0 1`.

## Q7 — Instructor por defecto

Resultado: 2 filas actualizadas.

El `SELECT` previo, con `instructor IS NULL`, devolvió las filas 10 y 11. El `UPDATE` escribió `Pending assignment` solo en esas filas. La etiqueta de comando fue `UPDATE 2`.

| id | student_name | student_email | course_title | instructor |
| --- | --- | --- | --- | --- |
| 10 | Yuki Nakamura | yuki.nakamura@student.edutrack.com | UI/UX Fundamentals | Pending assignment |
| 11 | Pierre Dubois | pierre.dubois@student.edutrack.com | UI/UX Fundamentals | Pending assignment |

La fila 18 no entra en esta corrección: ya llega con instructor Carlos Vega.

## Q8 — Borrado de cuentas @test.com

Resultado: 2 filas eliminadas.

El `SELECT` previo y el `DELETE` usan el mismo filtro (`student_email LIKE '%@test.com'`). La etiqueta de comando fue `DELETE 2`.

| id | student_name | student_email | course_title | category | completion_percentage | monthly_fee_paid |
| --- | --- | --- | --- | --- | --- | --- |
| 13 | James Miller | james.miller@test.com | Intro to Python | Programming | 30 | 49.99 |
| 14 | Alex Chen | alex.chen@test.com | Web Design Basics | Design | 10 | 39.99 |

Esas dos filas salen de `enrollments`. Las cuentas siguen en `students`. Después del alta y de este borrado la tabla queda en 16 inscripciones.

## Q9 — Inscripciones por categoría

Resultado:

- Programming: 7
- Design: 4
- Data: 3
- Marketing: 2

| category | enrollment_count |
| --- | --- |
| Programming | 7 |
| Design | 4 |
| Data | 3 |
| Marketing | 2 |

Suman 16. Programming no cambia de conteo respecto a la carga: pierde a James Miller y gana a Lucia Fernandes. Design pierde a Alex Chen y baja de 5 a 4. Data y Marketing no se mueven.

## Q10 — Promedio de avance por curso

Resultado: 6 cursos, de menor a mayor promedio. El valor es `AVG(completion_percentage)` sin redondear en la consulta.

| course_title | avg_completion_percentage |
| --- | --- |
| UI/UX Fundamentals | 0.00000000000000000000 |
| Web Design Basics | 32.5000000000000000 |
| Digital Marketing 101 | 36.5000000000000000 |
| Advanced Python | 45.0000000000000000 |
| Data Analysis with SQL | 47.6666666666666667 |
| Intro to Python | 80.0000000000000000 |

UI/UX Fundamentals es el curso con peor avance: las dos inscripciones están en 0. Intro to Python es el más alto. Data Analysis with SQL queda en 47.6666666666666667, que es el promedio exacto de tres enteros (143 / 3). Email Campaigns no tiene inscripciones y por eso no sale en el agrupado.

## Q11 — Cursos con más de 3 inscripciones

Resultado: 1

| course_title | enrollment_count |
| --- | --- |
| Intro to Python | 4 |

`HAVING COUNT(*) > 3` deja fuera a Data Analysis with SQL y a Advanced Python, que se quedan en 3. El umbral es estricto: 3 no basta.

## Q12 — Ingresos por categoría

Resultado:

- Programming: 409.93
- Data: 179.97
- Design: 169.96
- Marketing: 59.98

| category | total_revenue |
| --- | --- |
| Programming | 409.93 |
| Data | 179.97 |
| Design | 169.96 |
| Marketing | 59.98 |

La suma de las cuatro categorías es 819.84. Programming aporta algo más de la mitad. Marketing es la categoría con menos inscripciones y con menos ingreso. Design queda por debajo de Data: antes de quitar la cuenta de prueba iba por encima.

## Antes y después de las correcciones (Q6–Q8)

Esta sección complementa a Q1–Q12. El resultado oficial de cada consulta sigue en su propia sección. Aquí se ve qué movieron el alta, el relleno del instructor y el borrado.

### Estado de la tabla

| Medida | Antes | Después |
| --- | --- | --- |
| Inscripciones | 17 | 16 |
| Filas en `students` | 10 | 10 |
| Filas en `courses` | 7 | 7 |
| Instructor `NULL` | 2 | 0 |
| Inscripciones `@test.com` | 2 | 0 |
| Fila `id = 18` | 0 | 1 |

El hash del contenido de `students` y el de `courses` coinciden antes y después (`9040195f9dbefe6f0bc3b431f4f81cbd` y `13ff18accb70e8ce0394e19750c4865e` en `evidence/psql/07_run_stamp.txt`).

### Conteos e ingresos

| category | Inscripciones antes | Inscripciones después | Ingreso antes | Ingreso después | Diferencia de ingreso |
| --- | --- | --- | --- | --- | --- |
| Programming | 7 | 7 | 389.93 | 409.93 | +20.00 |
| Design | 5 | 4 | 209.95 | 169.96 | -39.99 |
| Data | 3 | 3 | 179.97 | 179.97 | 0.00 |
| Marketing | 2 | 2 | 59.98 | 59.98 | 0.00 |

El ingreso total pasa de 839.83 a 819.84, una baja de 19.99. Esa cifra es la cuota añadida (69.99) menos las dos cuotas de prueba que salen con el borrado (49.99 de James Miller y 39.99 de Alex Chen). El orden por ingreso cambia: antes era Programming, Design, Data, Marketing; después es Programming, Data, Design, Marketing.

### Promedio de avance

| course_title | Promedio antes | Promedio después |
| --- | --- | --- |
| UI/UX Fundamentals | 0.00000000000000000000 | 0.00000000000000000000 |
| Web Design Basics | 25.0000000000000000 | 32.5000000000000000 |
| Digital Marketing 101 | 36.5000000000000000 | 36.5000000000000000 |
| Data Analysis with SQL | 47.6666666666666667 | 47.6666666666666667 |
| Advanced Python | 67.5000000000000000 | 45.0000000000000000 |
| Intro to Python | 70.0000000000000000 | 80.0000000000000000 |

Advanced Python baja porque Q6 añade una inscripción con avance 0. Intro to Python sube porque Q8 quita la inscripción de James Miller, que en Q1 y en Q4 está al 30 %. Web Design Basics sube al quitar la inscripción de Alex Chen. UI/UX, Data Analysis with SQL y Digital Marketing 101 se quedan en el mismo promedio.

### Cursos por encima de 3 inscripciones

| Momento | course_title | enrollment_count |
| --- | --- | --- |
| Antes | Intro to Python | 5 |
| Después | Intro to Python | 4 |

Sigue habiendo un solo curso por encima del umbral. El conteo de ese curso baja en uno.

### Los mismos filtros de Q1, Q2, Q4 y Q5, repetidos al final

Dentro de `queries.sql`, Q1–Q5 se ejecutan una sola vez, antes de corregir. La tabla siguiente repite esos filtros al final para medir el efecto. La salida está en `evidence/psql/05b_filters_after.txt`.

| Filtro | Filas en Q1–Q5 | Filas si se repite al final | Qué cambia |
| --- | --- | --- | --- |
| Intro to Python | 5 | 4 | Sale James Miller. |
| Avance menor que 10 | 4 | 5 | Entra Lucia Fernandes, Advanced Python, avance 0 (`id` 18). |
| Cinco no aprobadas con mayor avance | 5 | 5 | El quinto puesto pasa de James Miller (30) a Pierre Dubois, Data Analysis with SQL (20). |
| Fecha desde 2024-07-01 | 9 | 10 | Entra la fila 18, con fecha 2025-04-01, la primera de la lista. |

El resultado oficial de Q2 sigue siendo 4 filas: esa consulta corre antes del `INSERT`. La quinta fila, Lucia Fernandes en Advanced Python con avance 0, aparece solo cuando el filtro se repite al final.

## Alcance

El trabajo de corrección vive en `enrollments`. `students` conserva a James Miller y a Alex Chen. `courses` sigue con 7 filas, incluida Email Campaigns, que no tiene inscripciones.

Los números de arriba son los de la corrida local. Para repetirlos en el SQL Editor de Supabase, el orden es el de `README.md`: primero `edutrack.sql`, después `queries.sql` de una sola vez.
