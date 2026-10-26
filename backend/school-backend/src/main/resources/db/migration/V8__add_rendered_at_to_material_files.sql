-- Migration V8: Bổ sung trường đánh dấu thời gian hoàn thành pre-render trang sách
ALTER TABLE material_files
    ADD COLUMN rendered_at TIMESTAMP DEFAULT NULL;

CREATE INDEX idx_material_files_rendered_at ON material_files(rendered_at);
