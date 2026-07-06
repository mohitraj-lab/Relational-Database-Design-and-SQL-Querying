
TASK 1.1 — NORMALIZATION STEPS WALKTHROUGH
-------------------------------------------------------------------------------
The unnormalized relation StudentRecords(student_id, student_name, department, 
advisor_name, advisor_email, course_code, course_name, instructor_name, 
instructor_email, enrollment_year, marks_obtained) with composite primary key 
(student_id, course_code) suffers from systemic relational anomalies.

A. Dependency Analysis:
   * Partial Dependencies (Non-key fields depending on a subset of the PK):
     - student_id -> student_name, department, advisor_name, advisor_email
     - course_code -> course_name, instructor_name, instructor_email
   * Transitive Dependencies (Functional chains across non-key fields):
     - student_id -> advisor_name -> advisor_email
     - course_code -> instructor_name -> instructor_email

B. Boyce-Codd Normal Form (BCNF) Decomposition:
   To ensure every non-trivial functional dependency X -> Y has a superkey as 
   its determinant X, the flat table is split into 5 distinct tables:
   1. Advisors(advisor_name [PK], advisor_email)
      - Resolves: advisor_name -> advisor_email transitive anomaly.
   2. Students(student_id [PK], student_name, department, advisor_name [FK])
      - Resolves: student profile partial dependencies on the composite key.
   3. Instructors(instructor_name [PK], instructor_email)
      - Resolves: instructor_name -> instructor_email transitive anomaly.
   4. Courses(course_code [PK], course_name, instructor_name [FK])
      - Resolves: course profile partial dependencies on the composite key.
   5. Enrollments(student_id [FK], course_code [FK], enrollment_year, marks_obtained)
      - Primary Key: (student_id, course_code)
      - Holds clean M:N intersection attributes without structural duplication.

C. Data Integrity Assessment:
   * Entity Integrity: Satisfied. Every table has a clearly defined primary 
     key column that does not accept NULL values.
   * Referential Integrity: Satisfied. All cross-table foreign key relationships 
     are hard-enforced via FOREIGN KEY constraints with explicit ON UPDATE/DELETE 
     cascade rules.
   * Domain Integrity: Satisfied. Data types (INT, VARCHAR, DECIMAL) strictly 
     limit column value types.
   * User-defined Integrity: Satisfied. Enforced through explicit domain rule 
     checks, including the chk_marks_bounds constraint (marks_obtained BETWEEN 0 AND 100).


2. SYSTEM DESIGN DECISIONS: DATA TYPES & CONSTRAINTS
-------------------------------------------------------------------------------
* student_id / INT: Best for indexing efficiency and fast query joins.
* course_code / VARCHAR(10): Accommodates standard alphanumeric academic keys 
  (e.g., 'CS101') while keeping storage small.
* marks_obtained / DECIMAL(5,2): Provides exact, fixed-point fractional 
  accuracy for academic scoring, avoiding the floating-point rounding errors 
  common with REAL or FLOAT data types.
* Referential Integrity Strategy: ON DELETE SET NULL is configured for entity 
  lookup fields (e.g., advisor_name), allowing student profiles to remain intact 
  if a faculty record is removed. Conversely, ON DELETE CASCADE is assigned to the 
  Enrollments junction table to automatically purge stale enrollment records if a 
  student profile or course code is deleted.


3. TASK 1.5 — CONCURRENCY & TRANSACTION ANALYSIS
-------------------------------------------------------------------------------
* Task 1.5b Concurrency Anomaly:
  - Anomaly Name: Non-repeatable Read.
  - Mitigation: Prevented at minimum by the REPEATABLE READ isolation level. 
    This guarantees that any row read within a transaction yields identical 
    data if re-read before committing.

* Task 1.5c Concurrency Anomaly:
  - Anomaly Name: Write Skew (a specific manifestation of phantom read patterns).
  - Mitigation: Requires the SERIALIZABLE isolation level. Because concurrent 
    transactions check shared states before making independent updates, execution 
    must be fully serialized to avoid violating the course capacity constraint.

* Task 1.5d MVCC Snapshot Isolation Mechanics:
  - Value Observed: The reporting transaction will read the original, un-updated 
    marks value, even after the concurrent write transaction commits.
  - Under the Hood: Multi-Version Concurrency Control (MVCC) stores point-in-time 
    historical deltas of updated rows rather than locking them. Active read queries 
    are served a consistent historical snapshot matching their start time, allowing 
    writers to modify rows without blocking readers.
  - Isolation Level: REPEATABLE READ (Snapshot Isolation).
  - Performance Trade-offs: Increases storage engine memory and undo-log overhead 
    to track multiple active row versions. It also increases the rate of 
    serialization/write-conflict failures, requiring robust retry logic in the 
    application code when parallel updates collide.
