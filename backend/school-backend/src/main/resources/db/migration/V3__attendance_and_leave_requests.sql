-- V3__attendance_and_leave_requests.sql
-- Bước 2: Attendance Sessions, Attendance Records và Leave Requests

BEGIN;

-- 1. Bảng phiên điểm danh (attendance_sessions)
CREATE TABLE IF NOT EXISTS attendance_sessions (
    id BIGSERIAL PRIMARY KEY,
    class_id BIGINT NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    lesson_slot INT DEFAULT NULL,
    submitted_by_teacher_id BIGINT REFERENCES teachers(id),
    status VARCHAR(20) DEFAULT 'SUBMITTED', -- 'DRAFT', 'SUBMITTED'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ràng buộc duy nhất: Một lớp chỉ có 1 phiên điểm danh trong ngày (nếu điểm danh cả ngày)
CREATE UNIQUE INDEX IF NOT EXISTS uq_session_daily 
ON attendance_sessions (class_id, date) 
WHERE lesson_slot IS NULL;

-- Hoặc 1 phiên cho từng tiết học
CREATE UNIQUE INDEX IF NOT EXISTS uq_session_slot 
ON attendance_sessions (class_id, date, lesson_slot) 
WHERE lesson_slot IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_session_class_date ON attendance_sessions(class_id, date);

-- 2. Bảng đơn xin nghỉ phép (leave_requests)
CREATE TABLE IF NOT EXISTS leave_requests (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    submitted_by_guardian_id BIGINT NOT NULL REFERENCES parents(id) ON DELETE CASCADE,
    reviewed_by_teacher_id BIGINT REFERENCES teachers(id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING', -- 'PENDING', 'APPROVED', 'REJECTED', 'CANCELLED'
    teacher_note TEXT,
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_leave_dates CHECK (end_date >= start_date)
);

CREATE INDEX IF NOT EXISTS idx_leave_student ON leave_requests(student_id);
CREATE INDEX IF NOT EXISTS idx_leave_guardian ON leave_requests(submitted_by_guardian_id);
CREATE INDEX IF NOT EXISTS idx_leave_status ON leave_requests(status);
CREATE INDEX IF NOT EXISTS idx_leave_dates ON leave_requests(student_id, start_date, end_date);

-- 3. Bảng bản ghi điểm danh học sinh (attendance_records)
CREATE TABLE IF NOT EXISTS attendance_records (
    id BIGSERIAL PRIMARY KEY,
    session_id BIGINT NOT NULL REFERENCES attendance_sessions(id) ON DELETE CASCADE,
    student_id BIGINT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL, -- 'PRESENT', 'ABSENT', 'LATE', 'LEAVE'
    remark VARCHAR(255),
    leave_request_id BIGINT REFERENCES leave_requests(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_session_student UNIQUE (session_id, student_id)
);

CREATE INDEX IF NOT EXISTS idx_record_session ON attendance_records(session_id);
CREATE INDEX IF NOT EXISTS idx_record_student ON attendance_records(student_id);
CREATE INDEX IF NOT EXISTS idx_record_leave ON attendance_records(leave_request_id);

-- =====================================================================
-- DML DATA BACKFILL (Chuyển đổi dữ liệu từ attendance cũ sang 2 tầng)
-- =====================================================================

-- Tạo session cho các lớp có điểm danh cũ
INSERT INTO attendance_sessions (class_id, date, status)
SELECT DISTINCT s.class_id, a.date, 'SUBMITTED'
FROM attendance a
JOIN students s ON a.student_id = s.id
WHERE s.class_id IS NOT NULL
ON CONFLICT (class_id, date) WHERE lesson_slot IS NULL DO NOTHING;

-- Đồng bộ records chi tiết
INSERT INTO attendance_records (session_id, student_id, status)
SELECT sess.id, a.student_id, a.status
FROM attendance a
JOIN students s ON a.student_id = s.id
JOIN attendance_sessions sess ON sess.class_id = s.class_id AND sess.date = a.date AND sess.lesson_slot IS NULL
ON CONFLICT (session_id, student_id) DO UPDATE 
SET status = EXCLUDED.status;

COMMIT;
