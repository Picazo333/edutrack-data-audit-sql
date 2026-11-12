-- Invariantes después de queries.sql.
-- El script de reproducción pasa :students_before y :courses_before.
-- Esta sesión crea una tabla temporal solo para leer esos dos números.

CREATE TEMP TABLE audit_expected_counts (
    students_before integer NOT NULL,
    courses_before integer NOT NULL
);

INSERT INTO audit_expected_counts (students_before, courses_before)
VALUES (:students_before, :courses_before);

DO $$
DECLARE
    n integer;
    students_now integer;
    courses_now integer;
    students_before integer;
    courses_before integer;
    sum_programming numeric;
    sum_data numeric;
    sum_design numeric;
    sum_marketing numeric;
    n_programming integer;
    n_design integer;
    n_data integer;
    n_marketing integer;
BEGIN
    SELECT a.students_before, a.courses_before
      INTO students_before, courses_before
      FROM audit_expected_counts AS a;

    IF (SELECT COUNT(*) FROM enrollments WHERE id = 18) <> 1 THEN
        RAISE EXCEPTION 'Q6: no está la fila id = 18';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM enrollments
        WHERE id = 18
          AND student_id = 3
          AND student_name = 'Lucia Fernandes'
          AND student_email = 'lucia.fernandes@student.edutrack.com'
          AND course_id = 5
          AND course_title = 'Advanced Python'
          AND category = 'Programming'
          AND enrollment_date = DATE '2025-04-01'
          AND completion_percentage = 0
          AND passed = FALSE
          AND monthly_fee_paid = 69.99
          AND instructor = 'Carlos Vega'
    ) THEN
        RAISE EXCEPTION 'Q6: la fila 18 no coincide con el comentario de edutrack.sql';
    END IF;

    SELECT COUNT(*) INTO n FROM enrollments WHERE instructor IS NULL;
    IF n <> 0 THEN
        RAISE EXCEPTION 'Q7: quedan % filas con instructor NULL', n;
    END IF;

    IF (SELECT instructor FROM enrollments WHERE id = 10) <> 'Pending assignment'
       OR (SELECT instructor FROM enrollments WHERE id = 11) <> 'Pending assignment' THEN
        RAISE EXCEPTION 'Q7: las filas 10 y 11 no quedaron en Pending assignment';
    END IF;

    IF (SELECT instructor FROM enrollments WHERE id = 1) IS DISTINCT FROM 'Marta López' THEN
        RAISE EXCEPTION 'Q7: se modificó un instructor que ya tenía valor';
    END IF;

    SELECT COUNT(*) INTO n
    FROM enrollments
    WHERE instructor = 'Pending assignment';
    IF n <> 2 THEN
        RAISE EXCEPTION 'Q7: se esperaban 2 filas con Pending assignment y hay %', n;
    END IF;

    SELECT COUNT(*) INTO n
    FROM enrollments
    WHERE student_email LIKE '%@test.com';
    IF n <> 0 THEN
        RAISE EXCEPTION 'Q8: quedan % inscripciones @test.com', n;
    END IF;

    IF EXISTS (SELECT 1 FROM enrollments WHERE id IN (13, 14)) THEN
        RAISE EXCEPTION 'Q8: las filas 13 y 14 siguen en enrollments';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM students WHERE email LIKE '%@test.com') THEN
        RAISE EXCEPTION 'students ya no tiene las cuentas @test.com; esa tabla no se debía modificar';
    END IF;

    SELECT COUNT(*) INTO n FROM enrollments;
    IF n <> 16 THEN
        RAISE EXCEPTION 'enrollments debería tener 16 filas (17 de la carga, +1, -2) y tiene %', n;
    END IF;

    SELECT COUNT(*) INTO students_now FROM students;
    SELECT COUNT(*) INTO courses_now FROM courses;
    IF students_now <> students_before THEN
        RAISE EXCEPTION 'cambió el número de filas de students (% -> %)', students_before, students_now;
    END IF;
    IF courses_now <> courses_before THEN
        RAISE EXCEPTION 'cambió el número de filas de courses (% -> %)', courses_before, courses_now;
    END IF;

    SELECT COUNT(*) INTO n_programming FROM enrollments WHERE category = 'Programming';
    SELECT COUNT(*) INTO n_design FROM enrollments WHERE category = 'Design';
    SELECT COUNT(*) INTO n_data FROM enrollments WHERE category = 'Data';
    SELECT COUNT(*) INTO n_marketing FROM enrollments WHERE category = 'Marketing';
    IF n_programming <> 7 OR n_design <> 4 OR n_data <> 3 OR n_marketing <> 2 THEN
        RAISE EXCEPTION
            'Q9: conteo Programming %, Design %, Data %, Marketing %',
            n_programming, n_design, n_data, n_marketing;
    END IF;

    IF (SELECT COUNT(*) FROM enrollments WHERE course_title = 'Intro to Python') <> 4 THEN
        RAISE EXCEPTION 'Q11: Intro to Python debería quedar con 4 inscripciones';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM (
            SELECT course_title
            FROM enrollments
            GROUP BY course_title
            HAVING COUNT(*) > 3
        ) AS cursos
    ) <> 1 THEN
        RAISE EXCEPTION 'Q11: debería haber un solo curso con más de 3 inscripciones';
    END IF;

    SELECT SUM(monthly_fee_paid) INTO sum_programming FROM enrollments WHERE category = 'Programming';
    SELECT SUM(monthly_fee_paid) INTO sum_data FROM enrollments WHERE category = 'Data';
    SELECT SUM(monthly_fee_paid) INTO sum_design FROM enrollments WHERE category = 'Design';
    SELECT SUM(monthly_fee_paid) INTO sum_marketing FROM enrollments WHERE category = 'Marketing';
    IF sum_programming <> 409.93
       OR sum_data <> 179.97
       OR sum_design <> 169.96
       OR sum_marketing <> 59.98 THEN
        RAISE EXCEPTION
            'Q12: Programming %, Data %, Design %, Marketing %',
            sum_programming, sum_data, sum_design, sum_marketing;
    END IF;
END
$$;
