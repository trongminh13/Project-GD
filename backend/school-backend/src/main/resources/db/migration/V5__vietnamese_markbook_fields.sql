-- ====================================================================
-- Migration: V5__vietnamese_markbook_fields.sql
-- Subsystem: Vietnamese Markbook & Academic Assessment (TT22 & TT27)
-- ====================================================================

-- 1. Thêm các cột phục vụ cấu trúc học bạ Việt Nam (Điểm thường xuyên, giữa kỳ, cuối kỳ, kỳ học)
ALTER TABLE marks ADD COLUMN IF NOT EXISTS exam_type VARCHAR(50) NOT NULL DEFAULT 'THUONG_XUYEN';
ALTER TABLE marks ADD COLUMN IF NOT EXISTS semester INT NOT NULL DEFAULT 1;
ALTER TABLE marks ADD COLUMN IF NOT EXISTS tx_index INT;
ALTER TABLE marks ADD COLUMN IF NOT EXISTS comment VARCHAR(500);
ALTER TABLE marks ADD COLUMN IF NOT EXISTS academic_year_id BIGINT REFERENCES academic_years(id);

-- 2. Backfill dữ liệu cũ đảm bảo tính toàn vẹn (idempotent)
UPDATE marks SET exam_type = 'THUONG_XUYEN' WHERE exam_type IS NULL;
UPDATE marks SET semester = 1 WHERE semester IS NULL;

-- 3. Chỉ mục phục vụ tra cứu bảng điểm học bạ nhanh theo học sinh và năm học
CREATE INDEX IF NOT EXISTS idx_marks_student_year_sem ON marks (student_id, academic_year_id, semester);
