-- V1__initial_schema.sql
-- Baseline initial schema capturing core legacy entities prior to Phase 1 foundation refactoring.
-- Designed to be 100% idempotent so it can run safely on both clean and existing databases.

BEGIN;

-- 1. Users table
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    must_change_password BOOLEAN DEFAULT false,
    failed_attempts INT DEFAULT 0,
    lock_time TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- 2. Teachers table
CREATE TABLE IF NOT EXISTS teachers (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(255) NOT NULL,
    qualification VARCHAR(255),
    subject_specialization VARCHAR(255),
    photo_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Classes table
CREATE TABLE IF NOT EXISTS classes (
    id BIGSERIAL PRIMARY KEY,
    grade VARCHAR(255) NOT NULL,
    section VARCHAR(255) NOT NULL,
    class_teacher_id BIGINT REFERENCES teachers(id),
    homeroom_teacher_id BIGINT REFERENCES teachers(id),
    CONSTRAINT classes_grade_section_key UNIQUE (grade, section)
);

-- 4. Parents table
CREATE TABLE IF NOT EXISTS parents (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Students table
CREATE TABLE IF NOT EXISTS students (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE REFERENCES users(id),
    admission_number VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    roll_no VARCHAR(255) NOT NULL,
    class_id BIGINT REFERENCES classes(id),
    parent_id BIGINT REFERENCES parents(id),
    aadhaar_masked VARCHAR(255),
    dob VARCHAR(255),
    gender VARCHAR(255),
    address TEXT,
    photo_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_students_user_id ON students(user_id);

-- 6. Subjects table
CREATE TABLE IF NOT EXISTS subjects (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(255) UNIQUE
);

-- 7. Class Subjects table (mapping)
CREATE TABLE IF NOT EXISTS class_subjects (
    class_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT
);

-- 8. Exams table
CREATE TABLE IF NOT EXISTS exams (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    start_date DATE,
    end_date DATE
);

-- 9. Marks table
CREATE TABLE IF NOT EXISTS marks (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT REFERENCES students(id),
    exam_id BIGINT REFERENCES exams(id),
    subject_id BIGINT REFERENCES subjects(id),
    score NUMERIC(38, 2),
    max_score NUMERIC(38, 2) DEFAULT 100.00
);

-- 10. Legacy Attendance table
CREATE TABLE IF NOT EXISTS attendance (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT REFERENCES students(id),
    date DATE NOT NULL,
    status VARCHAR(255) NOT NULL
);

-- 11. Fee Structure table
CREATE TABLE IF NOT EXISTS fee_structure (
    id BIGSERIAL PRIMARY KEY,
    class_id BIGINT REFERENCES classes(id),
    fee_type VARCHAR(255) NOT NULL,
    amount NUMERIC(38, 2) NOT NULL,
    due_month INT
);

-- 12. Fee Payments table
CREATE TABLE IF NOT EXISTS fee_payments (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT REFERENCES students(id),
    fee_structure_id BIGINT REFERENCES fee_structure(id),
    amount_paid NUMERIC(38, 2) NOT NULL,
    payment_date DATE DEFAULT CURRENT_DATE,
    transaction_id VARCHAR(255),
    status VARCHAR(255) DEFAULT 'PENDING',
    mode VARCHAR(255)
);

-- 13. Teacher Attendance table
CREATE TABLE IF NOT EXISTS teacher_attendance (
    id BIGSERIAL PRIMARY KEY,
    teacher_id BIGINT REFERENCES teachers(id),
    date DATE NOT NULL,
    status VARCHAR(255) NOT NULL
);

COMMIT;
