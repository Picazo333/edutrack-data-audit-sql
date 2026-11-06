-- Mismos filtros de lectura que Q1, Q2, Q4 y Q5.
-- No modifica datos. Sirve para comparar el antes y el después de Q6–Q8.

-- Q1
SELECT
    student_name,
    student_email,
    completion_percentage
FROM enrollments
WHERE course_title = 'Intro to Python'
ORDER BY student_name, student_email;

-- Q2
SELECT
    id,
    student_name,
    student_email,
    course_title,
    completion_percentage
FROM enrollments
WHERE completion_percentage < 10
ORDER BY completion_percentage, id;

-- Q4
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

-- Q5
SELECT
    id,
    student_name,
    student_email,
    course_title,
    enrollment_date
FROM enrollments
WHERE enrollment_date >= DATE '2024-07-01'
ORDER BY enrollment_date DESC, id DESC;
