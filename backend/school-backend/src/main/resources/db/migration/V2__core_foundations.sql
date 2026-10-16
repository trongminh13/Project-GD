-- V2__core_foundations.sql
-- Bước 1: Core Foundations Migration
-- Tạo bảng academic_years, enrollments, guardian_students, teaching_assignments
-- Ràng buộc toàn vẹn: UQ(student_id, academic_year_id), UQ(guardian_id, student_id), UQ(single is_current)
-- và backfill dữ liệu từ schema cũ.

BEGIN;

-- 1. Bảng năm học (academic_years)
CREATE TABLE IF NOT EXISTS academic_years (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN DEFAULT false,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ràng buộc duy nhất: Chỉ duy nhất 1 năm học được phép có is_current = true
CREATE UNIQUE INDEX IF NOT EXISTS uq_single_current_academic_year 
ON academic_years (is_current) 
WHERE is_current = true;

-- 2. Bảng phân lớp / ghi danh học sinh (enrollments)
CREATE TABLE IF NOT EXISTS enrollments (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    class_id BIGINT NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    academic_year_id BIGINT NOT NULL REFERENCES academic_years(id) ON DELETE RESTRICT,
    enrollment_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'ENROLLED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_student_academic_year UNIQUE (student_id, academic_year_id)
);

CREATE INDEX IF NOT EXISTS idx_enrollment_student ON enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_enrollment_class ON enrollments(class_id);
CREATE INDEX IF NOT EXISTS idx_enrollment_year ON enrollments(academic_year_id);

-- 3. Bảng liên kết Phụ huynh - Học sinh (guardian_students)
-- Ghi chú: relationship lưu vai trò (FATHER, MOTHER, GUARDIAN); is_primary là cờ liên hệ chính
CREATE TABLE IF NOT EXISTS guardian_students (
    id BIGSERIAL PRIMARY KEY,
    guardian_id BIGINT NOT NULL REFERENCES parents(id) ON DELETE CASCADE,
    student_id BIGINT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    relationship VARCHAR(50) DEFAULT 'GUARDIAN',
    is_primary BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_guardian_student UNIQUE (guardian_id, student_id)
);

CREATE INDEX IF NOT EXISTS idx_gs_guardian ON guardian_students(guardian_id);
CREATE INDEX IF NOT EXISTS idx_gs_student ON guardian_students(student_id);

-- 4. Bảng phân công giảng dạy (teaching_assignments)
CREATE TABLE IF NOT EXISTS teaching_assignments (
    id BIGSERIAL PRIMARY KEY,
    teacher_id BIGINT NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
    class_id BIGINT NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    subject_id BIGINT NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    academic_year_id BIGINT NOT NULL REFERENCES academic_years(id) ON DELETE RESTRICT,
    assignment_type VARCHAR(30) DEFAULT 'SUBJECT_TEACHER',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_teacher_class_subject_year UNIQUE (teacher_id, class_id, subject_id, academic_year_id)
);

CREATE INDEX IF NOT EXISTS idx_ta_teacher ON teaching_assignments(teacher_id);
CREATE INDEX IF NOT EXISTS idx_ta_class ON teaching_assignments(class_id);
CREATE INDEX IF NOT EXISTS idx_ta_year ON teaching_assignments(academic_year_id);

-- 5. Bổ sung trường homeroom_teacher_id vào bảng classes (nếu chưa có)
ALTER TABLE classes ADD COLUMN IF NOT EXISTS homeroom_teacher_id BIGINT REFERENCES teachers(id);

-- =====================================================================
-- DML DATA BACKFILL (Đồng bộ dữ liệu an toàn & Idempotent)
-- =====================================================================

-- Bước 5.1: Khởi tạo năm học hiện tại (2026-2027)
INSERT INTO academic_years (id, name, start_date, end_date, is_current, status)
VALUES (1, '2026-2027', '2026-09-01', '2027-06-30', true, 'ACTIVE')
ON CONFLICT (name) DO UPDATE 
SET is_current = true;

-- Đồng bộ sequence cho academic_years
SELECT setval('academic_years_id_seq', (SELECT COALESCE(MAX(id), 1) FROM academic_years));

-- Bước 5.2: Chuyển đổi classes.class_teacher_id -> homeroom_teacher_id
UPDATE classes 
SET homeroom_teacher_id = class_teacher_id 
WHERE homeroom_teacher_id IS NULL AND class_teacher_id IS NOT NULL;

-- Bước 5.3: Chuyển đổi students.class_id -> enrollments
INSERT INTO enrollments (student_id, class_id, academic_year_id, status, enrollment_date)
SELECT s.id, s.class_id, 1, 'ENROLLED', CURRENT_DATE
FROM students s
WHERE s.class_id IS NOT NULL
ON CONFLICT (student_id, academic_year_id) DO UPDATE 
SET class_id = EXCLUDED.class_id;

-- Bước 5.4: Chuyển đổi students.parent_id -> guardian_students (mặc định relationship = GUARDIAN)
INSERT INTO guardian_students (guardian_id, student_id, relationship, is_primary)
SELECT s.parent_id, s.id, 'GUARDIAN', true
FROM students s
WHERE s.parent_id IS NOT NULL
ON CONFLICT (guardian_id, student_id) DO UPDATE 
SET is_primary = true;

-- Bước 5.5: Chuyển đổi class_subjects (nếu có) -> teaching_assignments
INSERT INTO teaching_assignments (teacher_id, class_id, subject_id, academic_year_id, assignment_type)
SELECT cs.teacher_id, cs.class_id, cs.subject_id, 1, 'SUBJECT_TEACHER'
FROM class_subjects cs
WHERE cs.teacher_id IS NOT NULL
ON CONFLICT (teacher_id, class_id, subject_id, academic_year_id) DO NOTHING;

COMMIT;
