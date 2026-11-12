-- Comprobación de la carga. Solo lectura.

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

SELECT *
FROM enrollments
ORDER BY id
LIMIT 5;
