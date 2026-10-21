-- ====================================================================
-- Migration: V7__fix_markbook_score_range_and_conduct.sql
-- Subsystem: Vietnamese Markbook Strict Score Range & Constraint Hardening
-- ====================================================================

-- 1. Quy đổi chuẩn hóa dữ liệu cũ từ thang điểm 100 về thang điểm học bạ Việt Nam 10.0
UPDATE marks 
SET score = ROUND(score / 10.0, 1), 
    max_score = 10.00
WHERE score > 10.0 AND max_score >= 100.0;

-- 2. Điều chỉnh ràng buộc điểm số về thang điểm chuẩn Việt Nam [0.0, 10.0]
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_marks_score_range') THEN
        ALTER TABLE marks DROP CONSTRAINT chk_marks_score_range;
    END IF;
    ALTER TABLE marks ADD CONSTRAINT chk_marks_score_range
        CHECK (score IS NULL OR (score >= 0.0 AND score <= 10.0));
END $$;
