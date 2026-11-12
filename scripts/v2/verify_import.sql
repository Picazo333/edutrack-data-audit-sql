-- Comprobación de la carga del esquema normalizado. Solo lectura.
-- Las tres consultas LIMIT 5 son las del enunciado, sin ORDER BY.

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

SELECT 'courses' AS table_name, COUNT(*) AS rows FROM courses
UNION ALL
SELECT 'enrollments', COUNT(*) FROM enrollments
UNION ALL
SELECT 'students', COUNT(*) FROM students
ORDER BY table_name;

SELECT * FROM enrollments LIMIT 5;

SELECT * FROM students LIMIT 5;

SELECT * FROM courses LIMIT 5;
