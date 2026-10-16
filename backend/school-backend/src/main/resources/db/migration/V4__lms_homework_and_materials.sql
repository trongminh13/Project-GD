-- ====================================================================
-- Migration: V4__lms_homework_and_materials.sql
-- Subsystem: LMS (Homework & Learning Materials)
-- ====================================================================

-- 1. Bảng Kho Học liệu (Materials)
CREATE TABLE IF NOT EXISTS materials (
    id BIGSERIAL PRIMARY KEY,
    subject_id BIGINT NOT NULL REFERENCES subjects(id),
    created_by_teacher_id BIGINT NOT NULL REFERENCES teachers(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(30) NOT NULL DEFAULT 'PUBLISHED', -- DRAFT, PENDING_REVIEW, PUBLISHED, ARCHIVED
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS material_files (
    id BIGSERIAL PRIMARY KEY,
    material_id BIGINT NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    file_url TEXT NOT NULL,
    pdf_preview_url TEXT,
    page_count INT,
    version INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS material_classes (
    id BIGSERIAL PRIMARY KEY,
    material_id BIGINT NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
    class_id BIGINT NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    published_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_material_class UNIQUE (material_id, class_id)
);

CREATE TABLE IF NOT EXISTS material_reviews (
    id BIGSERIAL PRIMARY KEY,
    material_id BIGINT NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
    reviewed_by_user_id BIGINT NOT NULL REFERENCES users(id),
    status VARCHAR(30) NOT NULL, -- APPROVED, REJECTED
    review_notes TEXT,
    reviewed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Bảng Bài tập (Homework)
CREATE TABLE IF NOT EXISTS homework (
    id BIGSERIAL PRIMARY KEY,
    subject_id BIGINT NOT NULL REFERENCES subjects(id),
    created_by_teacher_id BIGINT NOT NULL REFERENCES teachers(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    notes TEXT,
    total_points DOUBLE PRECISION NOT NULL DEFAULT 10.0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS questions (
    id BIGSERIAL PRIMARY KEY,
    homework_id BIGINT NOT NULL REFERENCES homework(id) ON DELETE CASCADE,
    question_order INT NOT NULL DEFAULT 1,
    question_type VARCHAR(30) NOT NULL, -- SINGLE_CHOICE, MULTIPLE_CHOICE, TRUE_FALSE, ESSAY
    content TEXT NOT NULL,
    points DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    correct_answer_text TEXT,
    explanation TEXT
);

CREATE TABLE IF NOT EXISTS question_options (
    id BIGSERIAL PRIMARY KEY,
    question_id BIGINT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    option_order INT NOT NULL DEFAULT 1,
    content TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT FALSE
);

-- 3. Bảng Giao bài cho lớp (Homework Assignment)
CREATE TABLE IF NOT EXISTS homework_assignments (
    id BIGSERIAL PRIMARY KEY,
    homework_id BIGINT NOT NULL REFERENCES homework(id) ON DELETE CASCADE,
    class_id BIGINT NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    assigned_by_teacher_id BIGINT NOT NULL REFERENCES teachers(id),
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    due_date TIMESTAMP NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, CLOSED
    allow_late_submission BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_homework_class_assignment UNIQUE (homework_id, class_id)
);

-- 4. Bảng Bài làm của học sinh (Submission)
CREATE TABLE IF NOT EXISTS submissions (
    id BIGSERIAL PRIMARY KEY,
    assignment_id BIGINT NOT NULL REFERENCES homework_assignments(id) ON DELETE CASCADE,
    student_id BIGINT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    attempt_number INT NOT NULL DEFAULT 1,
    status VARCHAR(30) NOT NULL DEFAULT 'IN_PROGRESS', -- IN_PROGRESS, SUBMITTED, GRADED
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    submitted_at TIMESTAMP,
    is_late BOOLEAN NOT NULL DEFAULT FALSE,
    auto_score DOUBLE PRECISION DEFAULT 0.0,
    final_score DOUBLE PRECISION,
    teacher_feedback TEXT,
    graded_by_teacher_id BIGINT REFERENCES teachers(id),
    graded_at TIMESTAMP,
    CONSTRAINT uq_assignment_student_attempt UNIQUE (assignment_id, student_id, attempt_number)
);

-- 5. Bảng Trả lời từng câu hỏi (Answers & Selected Options)
CREATE TABLE IF NOT EXISTS answers (
    id BIGSERIAL PRIMARY KEY,
    submission_id BIGINT NOT NULL REFERENCES submissions(id) ON DELETE CASCADE,
    question_id BIGINT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    answer_text TEXT,
    is_auto_graded BOOLEAN NOT NULL DEFAULT FALSE,
    score DOUBLE PRECISION,
    teacher_note TEXT,
    CONSTRAINT uq_submission_question UNIQUE (submission_id, question_id)
);

CREATE TABLE IF NOT EXISTS answer_options (
    id BIGSERIAL PRIMARY KEY,
    answer_id BIGINT NOT NULL REFERENCES answers(id) ON DELETE CASCADE,
    option_id BIGINT NOT NULL REFERENCES question_options(id) ON DELETE CASCADE,
    CONSTRAINT uq_answer_selected_option UNIQUE (answer_id, option_id)
);

-- Indexes tối ưu truy vấn ReBAC
CREATE INDEX IF NOT EXISTS idx_homework_subject ON homework(subject_id);
CREATE INDEX IF NOT EXISTS idx_homework_teacher ON homework(created_by_teacher_id);
CREATE INDEX IF NOT EXISTS idx_hw_assign_class ON homework_assignments(class_id);
CREATE INDEX IF NOT EXISTS idx_submissions_assignment ON submissions(assignment_id);
CREATE INDEX IF NOT EXISTS idx_submissions_student ON submissions(student_id);
CREATE INDEX IF NOT EXISTS idx_material_classes_class ON material_classes(class_id);
