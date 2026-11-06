-- EduTrack — auditoría de la tabla enrollments
-- Ejecutar de arriba abajo, una sola vez, sobre la base recién cargada
-- con edutrack.sql. Q1–Q5 leen ese estado. Q6–Q8 lo corrigen.
-- Q9–Q12 agregan el resultado ya corregido.
-- No modifica students ni courses.
-- SQL de PostgreSQL, el mismo dialecto que usa Supabase.
-- SET solo fija el formato de las fechas en la sesión; no toca datos.

SET datestyle TO ISO, YMD;

-- Q1: inscripciones en 'Intro to Python'
-- Columnas pedidas: nombre, email y porcentaje de completado.
SELECT
    student_name,
    student_email,
    completion_percentage
FROM enrollments
WHERE course_title = 'Intro to Python'
ORDER BY student_name, student_email;

-- Q2: posibles abandonos (completion_percentage menor que 10)
SELECT
    id,
    student_name,
    student_email,
    course_title,
    completion_percentage
FROM enrollments
WHERE completion_percentage < 10
ORDER BY completion_percentage, id;

-- Q3: inscripciones con instructor NULL
SELECT
    id,
    student_name,
    student_email,
    course_title,
    instructor
FROM enrollments
WHERE instructor IS NULL
ORDER BY id;

-- Q4: cinco inscripciones no aprobadas con mayor completion_percentage
-- El filtro es passed = false y el corte es LIMIT 5.
-- Es un ranking de inscripciones: la misma persona puede salir más de una vez.
SELECT
    student_name,
    student_email,
    course_title,
    completion_percentage,
    passed
FROM enrollments
WHERE passed = FALSE
ORDER BY completion_percentage DESC, id
LIMIT 5;

-- Q5: inscripciones con fecha en o después de 2024-07-01, de la más reciente a la más antigua
SELECT
    id,
    student_name,
    student_email,
    course_title,
    enrollment_date
FROM enrollments
WHERE enrollment_date >= DATE '2024-07-01'
ORDER BY enrollment_date DESC, id DESC;

-- Q6: inscripción confirmada por correo y nunca cargada
-- Valores copiados del comentario MISSING RECORD de edutrack.sql. id = 18.
-- Verificación previa: esa fila todavía no está.
SELECT
    id,
    student_id,
    student_name,
    student_email,
    course_id,
    course_title,
    enrollment_date
FROM enrollments
WHERE id = 18
   OR (
        student_id = 3
        AND course_id = 5
        AND enrollment_date = DATE '2025-04-01'
      );

INSERT INTO enrollments (
    id,
    student_id,
    student_name,
    student_email,
    course_id,
    course_title,
    category,
    enrollment_date,
    completion_percentage,
    passed,
    monthly_fee_paid,
    instructor
) VALUES (
    18,
    3,
    'Lucia Fernandes',
    'lucia.fernandes@student.edutrack.com',
    5,
    'Advanced Python',
    'Programming',
    DATE '2025-04-01',
    0,
    FALSE,
    69.99,
    'Carlos Vega'
)
RETURNING
    id,
    student_id,
    student_name,
    student_email,
    course_id,
    course_title,
    category,
    enrollment_date,
    completion_percentage,
    passed,
    monthly_fee_paid,
    instructor;

-- Q7: rellenar el instructor donde llegó vacío
-- El SELECT usa el mismo WHERE que el UPDATE.
SELECT
    id,
    student_name,
    student_email,
    course_title,
    instructor
FROM enrollments
WHERE instructor IS NULL
ORDER BY id;

UPDATE enrollments
SET instructor = 'Pending assignment'
WHERE instructor IS NULL
RETURNING
    id,
    student_name,
    student_email,
    course_title,
    instructor;

-- Q8: quitar inscripciones de las cuentas importadas @test.com
-- El SELECT usa el mismo WHERE que el DELETE.
-- La tabla students no se toca.
SELECT
    id,
    student_name,
    student_email,
    course_title,
    category,
    completion_percentage,
    monthly_fee_paid
FROM enrollments
WHERE student_email LIKE '%@test.com'
ORDER BY id;

DELETE FROM enrollments
WHERE student_email LIKE '%@test.com'
RETURNING
    id,
    student_name,
    student_email,
    course_title,
    category,
    completion_percentage,
    monthly_fee_paid;

-- Q9: número de inscripciones por categoría, ya con Q6–Q8 aplicadas
SELECT
    category,
    COUNT(*) AS enrollment_count
FROM enrollments
GROUP BY category
ORDER BY enrollment_count DESC, category;

-- Q10: promedio de completion_percentage por curso, de menor a mayor
SELECT
    course_title,
    AVG(completion_percentage) AS avg_completion_percentage
FROM enrollments
GROUP BY course_title
ORDER BY avg_completion_percentage ASC, course_title;

-- Q11: cursos con más de 3 inscripciones
SELECT
    course_title,
    COUNT(*) AS enrollment_count
FROM enrollments
GROUP BY course_title
HAVING COUNT(*) > 3
ORDER BY enrollment_count DESC, course_title;

-- Q12: ingresos cobrados (SUM de monthly_fee_paid) por categoría, de mayor a menor
SELECT
    category,
    SUM(monthly_fee_paid) AS total_revenue
FROM enrollments
GROUP BY category
ORDER BY total_revenue DESC, category;
