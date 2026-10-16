-- =========================================================================
-- Rollback V1: Remove STUDENT role and security columns
-- Target Database: ashadeep_school_db (PostgreSQL)
-- =========================================================================

-- 1. Xóa liên kết user_id ở bảng students đối với các tài khoản STUDENT
UPDATE students SET user_id = NULL WHERE user_id IN (SELECT id FROM users WHERE role = 'STUDENT');

-- 2. Xóa các user có role STUDENT
DELETE FROM users WHERE role = 'STUDENT';

-- 3. Khôi phục lại CHECK constraint ban đầu
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;
ALTER TABLE users ADD CONSTRAINT users_role_check 
    CHECK (role IN ('ADMIN', 'TEACHER', 'PARENT'));

-- 4. Xóa các cột đã thêm
ALTER TABLE users DROP COLUMN IF EXISTS must_change_password;
ALTER TABLE users DROP COLUMN IF EXISTS failed_attempts;
ALTER TABLE users DROP COLUMN IF EXISTS lock_time;

-- 5. Xóa indexes
DROP INDEX IF EXISTS idx_users_username;
DROP INDEX IF EXISTS idx_students_user_id;
