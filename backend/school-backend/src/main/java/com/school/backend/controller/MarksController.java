package com.school.backend.controller;

import com.school.backend.entity.Marks;
import com.school.backend.payload.request.BulkMarksRequest;
import com.school.backend.payload.response.StudentMarkResponse;
import com.school.backend.payload.response.StudentMarkbookResponse;
import com.school.backend.service.MarksService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/marks")
public class MarksController {

    @Autowired
    private MarksService marksService;

    @PostMapping("/bulk")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER')")
    public ResponseEntity<List<Marks>> uploadClassMarks(@RequestBody BulkMarksRequest request) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        List<Marks> savedMarks = marksService.saveBulkMarks(request, auth);
        return ResponseEntity.ok(savedMarks);
    }

    @GetMapping("/student/{studentId}")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER') or hasAuthority('PARENT') or hasAuthority('STUDENT')")
    public ResponseEntity<List<StudentMarkResponse>> getStudentMarks(@PathVariable Long studentId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(marksService.getMarksByStudentId(studentId, auth));
    }

    @GetMapping("/{studentId}")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER') or hasAuthority('PARENT') or hasAuthority('STUDENT')")
    public ResponseEntity<List<StudentMarkResponse>> getStudentMarksAlias(@PathVariable Long studentId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(marksService.getMarksByStudentId(studentId, auth));
    }

    /**
     * Học bạ đầy đủ theo chuẩn Bộ GD&ĐT Việt Nam.
     * Trả về điểm TX/GK/CK theo từng học kỳ, DTB, xếp loại học lực cho tất cả các môn.
     * Kiểm soát an ninh BOLA chặt chẽ: Học sinh chỉ xem chính mình, Phụ huynh chỉ xem con mình.
     *
     * @param studentId      ID học sinh
     * @param academicYearId ID năm học (tùy chọn – mặc định năm hiện tại)
     */
    @GetMapping("/student/{studentId}/markbook")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER') or hasAuthority('PARENT') or hasAuthority('STUDENT')")
    public ResponseEntity<StudentMarkbookResponse> getStudentMarkbook(
            @PathVariable Long studentId,
            @RequestParam(required = false) Long academicYearId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        StudentMarkbookResponse markbook = marksService.getStudentMarkbook(studentId, academicYearId, auth);
        return ResponseEntity.ok(markbook);
    }

    /**
     * Cập nhật một con điểm lẻ (chỉ dành cho Admin hoặc Giáo viên phụ trách môn học).
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER')")
    public ResponseEntity<Marks> updateMark(
            @PathVariable Long id,
            @RequestParam(required = false) BigDecimal score,
            @RequestParam(required = false) String comment) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(marksService.updateSingleMark(id, score, comment, auth));
    }

    /**
     * Xóa một con điểm bị nhập nhầm (chỉ dành cho Admin hoặc Giáo viên phụ trách môn học).
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER')")
    public ResponseEntity<Void> deleteMark(@PathVariable Long id) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        marksService.deleteSingleMark(id, auth);
        return ResponseEntity.noContent().build();
    }
}

