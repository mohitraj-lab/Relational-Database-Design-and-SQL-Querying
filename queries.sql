-- TASK 1.3 -------------------------

-- a. Data Insertion 
INSERT INTO Advisors (advisor_name, advisor_email) VALUES
('Dr. Amit Sharma', 'asharma@university.edu'),
('Dr. Priya Nair', 'pnair@university.edu');

INSERT INTO Students (student_id, student_name, department, advisor_name) VALUES
(101, 'Aarav Mehta', 'Computer Science', 'Dr. Amit Sharma'),
(102, 'Ananya Iyer', 'Computer Science', 'Dr. Amit Sharma'),
(103, 'Vihaan Patel', 'Electrical Engineering', 'Dr. Priya Nair');

INSERT INTO Instructors (instructor_name, instructor_email) VALUES
('Prof. Rajesh Kumar', 'rkumar@university.edu'),
('Prof. Sunita Rao', 'srao@university.edu');

INSERT INTO Courses (course_code, course_name, instructor_name) VALUES
('CS101', 'Introduction to Programming', 'Prof. Sunita Rao'),
('CS202', 'Data Structures', 'Prof. Sunita Rao'),
('CS303', 'Quantum Computing', 'Prof. Rajesh Kumar');

INSERT INTO Enrollments (student_id, course_code, enrollment_year, marks_obtained) VALUES
(101, 'CS101', 2024, 88.50),
(101, 'CS202', 2025, 45.00),
(102, 'CS101', 2024, 32.00), 
(102, 'CS303', 2024, 75.00),
(103, 'CS303', 2025, 92.00);


-- b. update statement application 
UPDATE Instructors 
SET instructor_email = 'sunita.rao@university.edu' 
WHERE instructor_name = 'Prof. Sunita Rao';


-- c. Delete Enrollment Records below 35 Marks
DELETE FROM Enrollments 
WHERE marks_obtained < 35.00;


-- d. Bulk removal discussion on old flat table
-- DELETE FROM StudentRecords;
/* 
   EXPLANATION: 
   DELETE is a DML statement which ensures it is safe within transaction controls. 
   When executed inside a transaction block (BEGIN...ROLLBACK), DELETE logs rows and respects 
   the ROLLBACK statement in all major relational databases. 
   Conversely, TRUNCATE is treated as a DDL statement in engines like MySQL; it triggers an 
   implicit commit instantly, permanently wiping out data and destroying any option to rollback 
   aborted transactions. In PostgreSQL, TRUNCATE is transactional, but to maintain portable, 
   rollback-safe scripts across multi-database environments, DELETE is the reliable mechanism.
*/


-- TASK 1.4 ------------------------------

-- a. retrival of student with a course code CS101,CS202,CS303 
SELECT s.student_name, c.course_name
FROM Enrollments e
JOIN Students s ON e.student_id = s.student_id
JOIN Courses c ON e.course_code = c.course_code
WHERE e.course_code IN ('CS101', 'CS202', 'CS303');


-- b. retrival of student whose marks in beteen 60.00 and 85.00 and advisior email is not null
SELECT s.*
FROM Students s
JOIN Advisors a ON s.advisor_name = a.advisor_name
JOIN Enrollments e ON s.student_id = e.student_id
WHERE e.marks_obtained BETWEEN 60.00 AND 85.00
  AND a.advisor_email IS NOT NULL;


-- c. computing the avg min and max marks and avg should be more than 55.00 
SELECT s.department,
       AVG(e.marks_obtained) AS average_marks,
       MIN(e.marks_obtained) AS minimum_marks,
       MAX(e.marks_obtained) AS maximum_marks
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
GROUP BY s.department
HAVING AVG(e.marks_obtained) > 55.00;


-- d. Comparison: INNER JOIN vs LEFT JOIN outputs
-- Query 1: INNER JOIN
SELECT s.student_name, c.course_name, e.marks_obtained
FROM Students s
INNER JOIN Enrollments e ON s.student_id = e.student_id
INNER JOIN Courses c ON e.course_code = c.course_code;

-- Query 2: LEFT JOIN
SELECT s.student_name, c.course_name, e.marks_obtained
FROM Students s
LEFT JOIN Enrollments e ON s.student_id = e.student_id
LEFT JOIN Courses c ON e.course_code = c.course_code;


-- e. Correlated subquery to find above-average performers in their department
SELECT s.student_name, e.marks_obtained
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
WHERE e.marks_obtained > (
    SELECT AVG(e2.marks_obtained)
    FROM Students s2
    JOIN Enrollments e2 ON s2.student_id = e2.student_id
    WHERE s2.department = s.department
);


-- f. Set operations evaluating how many student left (2024 vs 2025)
SELECT student_id FROM Enrollments WHERE enrollment_year = 2024
EXCEPT
SELECT student_id FROM Enrollments WHERE enrollment_year = 2025;


-- g. Correlated subquery finding the exact 2nd-highest score per department
SELECT s.student_name, e.marks_obtained, s.department
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
WHERE 1 = (
    SELECT COUNT(DISTINCT e2.marks_obtained)
    FROM Students s2
    JOIN Enrollments e2 ON s2.student_id = e2.student_id
    WHERE s2.department = s.department 
      AND e2.marks_obtained > e.marks_obtained
)
-- Exclude departments containing only one student entry completely
AND (
    SELECT COUNT(DISTINCT s3.student_id) 
    FROM Students s3 
    WHERE s3.department = s.department
) > 1;


-- h. Analytical evaluation comparing different SQL window rank functions
SELECT s.department, s.student_name, e.marks_obtained,
       ROW_NUMBER() OVER(PARTITION BY s.department ORDER BY e.marks_obtained DESC) AS row_num,
       RANK()       OVER(PARTITION BY s.department ORDER BY e.marks_obtained DESC) AS rnk,
       DENSE_RANK() OVER(PARTITION BY s.department ORDER BY e.marks_obtained DESC) AS dense_rnk
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id;