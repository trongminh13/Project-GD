-- ====================================================================
-- Migration: V6__markbook_constraints_and_validation.sql
-- Subsystem: Vietnamese Markbook Integrity & Constraints (TT22 & TT27)
-- ====================================================================

-- 1. Partial Unique Index chống nhập trùng bài thi Giữa kỳ và Cuối kỳ (khi tx_index là NULL)
CREATE UNIQUE INDEX IF NOT EXISTS uq_marks_single_exam
ON marks (student_id, subject_id, semester, academic_year_id, exam_type)
WHERE exam_type IN ('GIUA_KY', 'CUOI_KY');

-- 2. Partial Unique Index chống nhập trùng thứ tự cột điểm thường xuyên TX (TX1, TX2, TX3...)
CREATE UNIQUE INDEX IF NOT EXISTS uq_marks_tx_index
ON marks (student_id, subject_id, semester, academic_year_id, exam_type, tx_index)
WHERE exam_type = 'THUONG_XUYEN' AND tx_index IS NOT NULL;

-- 3. Ràng buộc học kỳ hợp lệ (Học kỳ 1 hoặc Học kỳ 2)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_marks_semester') THEN
        ALTER TABLE marks ADD CONSTRAINT chk_marks_semester CHECK (semester IN (1, 2));
    END IF;
END $$;

-- 4. Ràng buộc khoảng điểm hợp lệ (từ 0 đến 100 hoặc NULL đối với môn nhận xét)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_marks_score_range') THEN
        ALTER TABLE marks ADD CONSTRAINT chk_marks_score_range CHECK (score IS NULL OR (score >= 0 AND score <= 100));
    END IF;
END $$;
