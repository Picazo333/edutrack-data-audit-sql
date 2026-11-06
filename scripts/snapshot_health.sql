-- Lectura de control. No inserta, no actualiza y no borra.
-- Se corre dos veces: antes de queries.sql y después.

SELECT COUNT(*) AS enrollments FROM enrollments;
SELECT COUNT(*) AS students FROM students;
SELECT COUNT(*) AS courses FROM courses;
SELECT COUNT(*) AS null_instructor FROM enrollments WHERE instructor IS NULL;
SELECT COUNT(*) AS test_com_enrollments
FROM enrollments
WHERE student_email LIKE '%@test.com';
SELECT COUNT(*) AS id_18 FROM enrollments WHERE id = 18;

SELECT category, COUNT(*) AS enrollment_count
FROM enrollments
GROUP BY category
ORDER BY enrollment_count DESC, category;

SELECT course_title, AVG(completion_percentage) AS avg_completion_percentage
FROM enrollments
GROUP BY course_title
ORDER BY avg_completion_percentage ASC, course_title;

SELECT course_title, COUNT(*) AS enrollment_count
FROM enrollments
GROUP BY course_title
HAVING COUNT(*) > 3
ORDER BY enrollment_count DESC, course_title;

SELECT category, SUM(monthly_fee_paid) AS total_revenue
FROM enrollments
GROUP BY category
ORDER BY total_revenue DESC, category;
