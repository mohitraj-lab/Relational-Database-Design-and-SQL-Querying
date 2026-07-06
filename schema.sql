-- task 1.2 solution

CREATE TABLE Advisors (
    advisor_name VARCHAR(100) PRIMARY KEY,
    advisor_email VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    advisor_name VARCHAR(100),
    CONSTRAINT fk_student_advisor FOREIGN KEY (advisor_name) 
        REFERENCES Advisors(advisor_name) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE Instructors (
    instructor_name VARCHAR(100) PRIMARY KEY,
    instructor_email VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE Courses (
    course_code VARCHAR(10) PRIMARY KEY,
    course_name VARCHAR(150) NOT NULL,
    instructor_name VARCHAR(100),
    CONSTRAINT fk_course_instructor FOREIGN KEY (instructor_name) 
        REFERENCES Instructors(instructor_name) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE Enrollments (
    student_id INT,
    course_code VARCHAR(10),
    enrollment_year INT DEFAULT 2026, -- Set to current year
    marks_obtained DECIMAL(5, 2),
    PRIMARY KEY (student_id, course_code),
    CONSTRAINT fk_enrollment_student FOREIGN KEY (student_id) 
        REFERENCES Students(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_enrollment_course FOREIGN KEY (course_code) 
        REFERENCES Courses(course_code) ON DELETE CASCADE,
    CONSTRAINT chk_marks CHECK (marks_obtained BETWEEN 0.00 AND 100.00)
);

-- TASK 1.5 -------------------------------------------

BEGIN;

-- Remove old enrollment entry for student Aarav Mehta (101)
DELETE FROM Enrollments 
WHERE student_id = 101 AND course_code = 'CS101';

-- Attempt to insert new destination enrollment entry
INSERT INTO Enrollments (student_id, course_code, enrollment_year, marks_obtained)
VALUES (101, 'CS404', 2026, NULL);

COMMIT;