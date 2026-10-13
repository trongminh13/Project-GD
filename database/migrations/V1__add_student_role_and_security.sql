-- =========================================================================
-- Migration V1: Add STUDENT role, enforce password change & login lockout
-- Target Database: ashadeep_school_db (PostgreSQL)
-- =========================================================================

-- 1. Nới lỏng CHECK constraint trên bảng users để chấp nhận role STUDENT
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;
ALTER TABLE users ADD CONSTRAINT users_role_check 
    CHECK (role IN ('ADMIN', 'TEACHER', 'PARENT', 'STUDENT'));

-- 2. Bổ sung các cột phục vụ cưỡng chế đổi pass & phòng thủ brute-force
ALTER TABLE users ADD COLUMN IF NOT EXISTS must_change_password BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS failed_attempts INT DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS lock_time TIMESTAMP NULL;

-- 3. Tạo index phục vụ tra cứu nhanh
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_students_user_id ON students(user_id);
