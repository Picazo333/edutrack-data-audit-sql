-- EduTrack v2 — auditoría del esquema normalizado
-- Ejecutar de arriba abajo sobre una base recién cargada con edutrack_v2.sql.
-- Cada consulta usa al menos un JOIN. No hay subconsultas.
-- No modifica datos.
-- SQL de PostgreSQL, el mismo dialecto que usa Supabase.
-- SET solo fija el formato de las fechas en la sesión; no toca datos.

SET datestyle TO ISO, YMD;

-- Q1: cada inscripción, con el nombre del estudiante, el título del curso y el avance
SELECT
    s.name AS student_name,
    c.title AS course_title,
    e.completion_percentage
FROM enrollments AS e
INNER JOIN students AS s ON s.id = e.student_id
INNER JOIN courses AS c ON c.id = e.course_id
ORDER BY s.name ASC, c.title ASC, e.id ASC;

-- Q2: estudiantes con al menos un curso aprobado, nombre, email y título de ese curso
-- Una fila por inscripción aprobada. Quien aprobó dos cursos sale dos veces.
SELECT
    s.name AS student_name,
    s.email AS student_email,
    c.title AS course_title
FROM enrollments AS e
INNER JOIN students AS s ON s.id = e.student_id
INNER JOIN courses AS c ON c.id = e.course_id
WHERE e.passed = TRUE
ORDER BY s.name ASC, c.title ASC, e.id ASC;

-- Q3: porcentaje de completado medio por instructor, de mayor a menor
SELECT
    c.instructor_name,
    AVG(e.completion_percentage) AS avg_completion_percentage
FROM enrollments AS e
INNER JOIN courses AS c ON c.id = e.course_id
GROUP BY c.instructor_name
ORDER BY avg_completion_percentage DESC, c.instructor_name ASC;

-- Q4: estudiantes registrados que no tienen ninguna inscripción
SELECT
    s.id,
    s.name,
    s.email,
    s.signup_date
FROM students AS s
LEFT JOIN enrollments AS e ON e.student_id = s.id
WHERE e.id IS NULL
ORDER BY s.id ASC;

-- Q5: cursos del catálogo que no tienen ninguna inscripción
SELECT
    c.id,
    c.title,
    c.category,
    c.instructor_name,
    c.monthly_fee
FROM courses AS c
LEFT JOIN enrollments AS e ON e.course_id = c.id
WHERE e.id IS NULL
ORDER BY c.id ASC;

-- Q6: estudiantes inscritos en más de un curso
SELECT
    s.name AS student_name,
    COUNT(e.course_id) AS course_count
FROM students AS s
INNER JOIN enrollments AS e ON e.student_id = s.id
GROUP BY s.id, s.name
HAVING COUNT(e.course_id) > 1
ORDER BY course_count DESC, s.name ASC;

-- Q7: ingresos por categoría con el precio actual del curso (courses.monthly_fee)
-- No usa el pago histórico guardado en la inscripción.
SELECT
    c.category,
    SUM(c.monthly_fee) AS total_revenue
FROM enrollments AS e
INNER JOIN courses AS c ON c.id = e.course_id
GROUP BY c.category
ORDER BY total_revenue DESC, c.category ASC;

-- Q8: cada instructor y cuántos estudiantes distintos tienen inscripción en sus cursos
-- LEFT JOIN: un instructor sin estudiantes seguiría en la lista, con recuento 0.
SELECT
    c.instructor_name,
    COUNT(DISTINCT e.student_id) AS student_count
FROM courses AS c
LEFT JOIN enrollments AS e ON e.course_id = c.id
GROUP BY c.instructor_name
ORDER BY student_count DESC, c.instructor_name ASC;

-- Q9: inscripciones cuyo student_id no corresponde a ningún estudiante
SELECT
    e.id,
    e.student_id,
    e.course_id,
    e.enrollment_date
FROM enrollments AS e
LEFT JOIN students AS s ON s.id = e.student_id
WHERE s.id IS NULL
ORDER BY e.id ASC;

-- Q10: inscripciones cuyo course_id no corresponde a ningún curso
SELECT
    e.id,
    e.student_id,
    e.course_id,
    e.enrollment_date
FROM enrollments AS e
LEFT JOIN courses AS c ON c.id = e.course_id
WHERE c.id IS NULL
ORDER BY e.id ASC;
