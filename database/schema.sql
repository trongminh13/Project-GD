-- Student Management System Schema

-- 1. Users & Roles
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('ADMIN', 'TEACHER', 'PARENT', 'STUDENT')),
    must_change_password BOOLEAN DEFAULT FALSE,
    failed_attempts INT DEFAULT 0,
    lock_time TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Profiles
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    user_id INT UNIQUE REFERENCES users(id), -- Optional: if students have login
    admission_number VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    roll_no VARCHAR(20) NOT NULL,
    class_id INT, -- FK to classes
    parent_id INT, -- FK to parents
    aadhaar_masked VARCHAR(20),
    dob DATE,
    gender VARCHAR(10),
    address TEXT,
    photo_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE parents (
    id SERIAL PRIMARY KEY,
    user_id INT UNIQUE REFERENCES users(id),
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(100),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE teachers (
    id SERIAL PRIMARY KEY,
    user_id INT UNIQUE REFERENCES users(id),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) NOT NULL,
    qualification VARCHAR(100),
    subject_specialization VARCHAR(100),
    photo_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Academics
CREATE TABLE classes (
    id SERIAL PRIMARY KEY,
    grade VARCHAR(10) NOT NULL,
    section VARCHAR(10) NOT NULL,
    class_teacher_id INT REFERENCES teachers(id),
    UNIQUE (grade, section)
);

CREATE TABLE subjects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    code VARCHAR(20) UNIQUE
);

CREATE TABLE class_subjects (
    class_id INT REFERENCES classes(id),
    subject_id INT REFERENCES subjects(id),
    teacher_id INT REFERENCES teachers(id),
    PRIMARY KEY (class_id, subject_id)
);

-- Foreign Key for students table (defined after classes/parents creation to avoid errors if run sequentially)
ALTER TABLE students ADD CONSTRAINT fk_student_class FOREIGN KEY (class_id) REFERENCES classes(id);
ALTER TABLE students ADD CONSTRAINT fk_student_parent FOREIGN KEY (parent_id) REFERENCES parents(id);

-- 4. Fees
CREATE TABLE fee_structure (
    id SERIAL PRIMARY KEY,
    class_id INT REFERENCES classes(id),
    fee_type VARCHAR(50) NOT NULL CHECK (fee_type IN ('TUITION', 'ANNUAL', 'BOARD', 'DEVELOPMENT', 'BOOKS', 'UNIFORM')),
    amount DECIMAL(10, 2) NOT NULL,
    due_month INT, -- e.g., 4 for April
    UNIQUE (class_id, fee_type)
);

CREATE TABLE fee_payments (
    id SERIAL PRIMARY KEY,
    student_id INT REFERENCES students(id),
    fee_structure_id INT REFERENCES fee_structure(id),
    amount_paid DECIMAL(10, 2) NOT NULL,
    payment_date DATE DEFAULT CURRENT_DATE,
    transaction_id VARCHAR(100),
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PAID', 'LATE')),
    mode VARCHAR(20) -- CASH, ONLINE
);

-- 5. Attendance & Results
CREATE TABLE attendance (
    id SERIAL PRIMARY KEY,
    student_id INT REFERENCES students(id),
    date DATE NOT NULL,
    status VARCHAR(10) NOT NULL CHECK (status IN ('PRESENT', 'ABSENT', 'LATE', 'LEAVE')),
    UNIQUE (student_id, date)
);

CREATE TABLE teacher_attendance (
    id SERIAL PRIMARY KEY,
    teacher_id INT REFERENCES teachers(id),
    date DATE NOT NULL,
    status VARCHAR(10) NOT NULL CHECK (status IN ('PRESENT', 'ABSENT', 'LEAVE')),
    UNIQUE (teacher_id, date)
);

CREATE TABLE exams (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL, -- e.g., "Term 1", "Unit Test 1"
    start_date DATE,
    end_date DATE
);

CREATE TABLE marks (
    id SERIAL PRIMARY KEY,
    student_id INT REFERENCES students(id),
    exam_id INT REFERENCES exams(id),
    subject_id INT REFERENCES subjects(id),
    score DECIMAL(5, 2),
    max_score DECIMAL(5, 2) DEFAULT 100.00,
    UNIQUE (student_id, exam_id, subject_id)
);

-- Seed Initial Admin User
-- Password is 'admin123' (hashed usually, but plain for initial setup if no encryptor used yet or handled by app)
INSERT INTO users (username, password, role) VALUES ('admin', 'admin123', 'ADMIN');
