-- Cierra la corrida. Falla si la carga oficial no cuadra con estos invariantes.
-- Los números salen del archivo edutrack_v2.sql, contados aparte de queries.sql.

DO $$
DECLARE
    n integer;
    rev numeric;
    avg_marta numeric;
    fk_count integer;
BEGIN
    IF (SELECT COUNT(*) FROM students) <> 8 THEN
        RAISE EXCEPTION 'students: se esperaban 8';
    END IF;

    IF (SELECT COUNT(*) FROM courses) <> 7 THEN
        RAISE EXCEPTION 'courses: se esperaban 7';
    END IF;

    IF (SELECT COUNT(*) FROM enrollments) <> 16 THEN
        RAISE EXCEPTION 'enrollments: se esperaban 16';
    END IF;

    SELECT COUNT(*)
      INTO fk_count
      FROM pg_constraint AS con
      INNER JOIN pg_class AS rel ON rel.oid = con.conrelid
     WHERE con.contype = 'f'
       AND rel.relname = 'enrollments';

    IF fk_count <> 2 THEN
        RAISE EXCEPTION 'se esperaban 2 claves foráneas en enrollments, hay %', fk_count;
    END IF;

    SELECT COUNT(*)
      INTO n
      FROM enrollments AS e
      LEFT JOIN students AS s ON s.id = e.student_id
     WHERE s.id IS NULL;

    IF n <> 0 THEN
        RAISE EXCEPTION 'huérfanos por student_id: % (esperado 0)', n;
    END IF;

    SELECT COUNT(*)
      INTO n
      FROM enrollments AS e
      LEFT JOIN courses AS c ON c.id = e.course_id
     WHERE c.id IS NULL;

    IF n <> 0 THEN
        RAISE EXCEPTION 'huérfanos por course_id: % (esperado 0)', n;
    END IF;

    IF (
        SELECT COUNT(*)
          FROM students AS s
          LEFT JOIN enrollments AS e ON e.student_id = s.id
         WHERE s.email = 'giulia.romano@student.edutrack.com'
           AND e.id IS NULL
    ) <> 1 THEN
        RAISE EXCEPTION 'Giulia Romano debería estar sin inscripciones';
    END IF;

    IF (
        SELECT COUNT(*)
          FROM courses AS c
          LEFT JOIN enrollments AS e ON e.course_id = c.id
         WHERE c.title = 'Email Campaigns'
           AND e.id IS NULL
    ) <> 1 THEN
        RAISE EXCEPTION 'Email Campaigns debería estar sin inscripciones';
    END IF;

    IF (
        SELECT COUNT(*)
          FROM enrollments AS e
         INNER JOIN courses AS c ON c.id = e.course_id
         WHERE e.passed = TRUE
    ) <> 6 THEN
        RAISE EXCEPTION 'se esperaban 6 inscripciones aprobadas';
    END IF;

    IF (
        SELECT COUNT(*)
          FROM (
              SELECT s.id
                FROM students AS s
                INNER JOIN enrollments AS e ON e.student_id = s.id
               GROUP BY s.id
              HAVING COUNT(e.course_id) > 1
          ) AS multi
    ) <> 7 THEN
        RAISE EXCEPTION 'se esperaban 7 estudiantes con más de un curso';
    END IF;

    SELECT SUM(c.monthly_fee)
      INTO rev
      FROM enrollments AS e
      INNER JOIN courses AS c ON c.id = e.course_id
     WHERE c.category = 'Programming';

    IF rev <> 409.93 THEN
        RAISE EXCEPTION 'ingreso Programming: % (esperado 409.93)', rev;
    END IF;

    SELECT SUM(c.monthly_fee)
      INTO rev
      FROM enrollments AS e
      INNER JOIN courses AS c ON c.id = e.course_id
     WHERE c.category = 'Data';

    IF rev <> 179.97 THEN
        RAISE EXCEPTION 'ingreso Data: % (esperado 179.97)', rev;
    END IF;

    SELECT SUM(c.monthly_fee)
      INTO rev
      FROM enrollments AS e
      INNER JOIN courses AS c ON c.id = e.course_id
     WHERE c.category = 'Design';

    IF rev <> 169.96 THEN
        RAISE EXCEPTION 'ingreso Design: % (esperado 169.96)', rev;
    END IF;

    SELECT SUM(c.monthly_fee)
      INTO rev
      FROM enrollments AS e
      INNER JOIN courses AS c ON c.id = e.course_id
     WHERE c.category = 'Marketing';

    IF rev <> 59.98 THEN
        RAISE EXCEPTION 'ingreso Marketing: % (esperado 59.98)', rev;
    END IF;

    SELECT AVG(e.completion_percentage)
      INTO avg_marta
      FROM enrollments AS e
      INNER JOIN courses AS c ON c.id = e.course_id
     WHERE c.instructor_name = 'Marta López';

    IF avg_marta <> (463::numeric / 7) THEN
        RAISE EXCEPTION 'promedio Marta López: % (esperado 463/7)', avg_marta;
    END IF;

    IF (
        SELECT COUNT(*)
          FROM enrollments AS e
          INNER JOIN courses AS c ON c.id = e.course_id
         WHERE e.monthly_fee_paid <> c.monthly_fee
    ) <> 0 THEN
        RAISE EXCEPTION 'hay pagos históricos distintos del precio actual';
    END IF;

    IF (
        SELECT COUNT(DISTINCT e.student_id)
          FROM enrollments AS e
          INNER JOIN courses AS c ON c.id = e.course_id
         WHERE c.instructor_name = 'Marta López'
    ) <> 6 THEN
        RAISE EXCEPTION 'Marta López debería tener 6 estudiantes distintos';
    END IF;

    IF (
        SELECT COUNT(DISTINCT e.student_id)
          FROM enrollments AS e
          INNER JOIN courses AS c ON c.id = e.course_id
         WHERE c.instructor_name = 'Carlos Vega'
    ) <> 3 THEN
        RAISE EXCEPTION 'Carlos Vega debería tener 3 estudiantes distintos';
    END IF;
END $$;

SELECT 'assert=pass' AS result;
