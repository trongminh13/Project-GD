package com.school.backend.service;

import com.school.backend.entity.*;
import com.school.backend.enums.EducationLevel;
import com.school.backend.enums.ExamType;
import com.school.backend.payload.dto.SemesterMarkDto;
import com.school.backend.payload.dto.SubjectMarkbookDto;
import com.school.backend.payload.request.BulkMarksRequest;
import com.school.backend.payload.response.StudentMarkResponse;
import com.school.backend.payload.response.StudentMarkbookResponse;
import com.school.backend.repository.*;
import com.school.backend.security.SchoolAccessPolicy;
import com.school.backend.util.MarksCalculationHelper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class MarksService {

    private static final Logger log = LoggerFactory.getLogger(MarksService.class);

    @Autowired
    private MarksRepository marksRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private ParentRepository parentRepository;

    @Autowired
    private GuardianStudentRepository guardianStudentRepository;

    @Autowired
    private TeacherRepository teacherRepository;

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private TeachingAssignmentRepository teachingAssignmentRepository;

    @Autowired
    private ExamRepository examRepository;

    @Autowired
    private SubjectRepository subjectRepository;

    @Autowired
    private AcademicYearRepository academicYearRepository;

    @Autowired
    private SchoolAccessPolicy schoolAccessPolicy;

    public void verifyTeacherAuthorizedForStudent(Student student, String teacherUsername) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        schoolAccessPolicy.verifyCanAccessStudent(auth, student.getId());
    }

    @Transactional(rollbackFor = Exception.class)
    public List<Marks> saveBulkMarks(BulkMarksRequest request, String currentUsername, boolean isTeacher) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return saveBulkMarks(request, auth);
    }

    @Transactional(rollbackFor = Exception.class)
    public List<Marks> saveBulkMarks(BulkMarksRequest request, Authentication auth) {
        if (request == null || request.getRecords() == null || request.getRecords().isEmpty()) {
            return new ArrayList<>();
        }

        // 1. Resolve Exam
        Exam exam = null;
        if (request.getExamId() != null) {
            exam = examRepository.findById(request.getExamId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy kỳ thi với ID: " + request.getExamId()));
        } else if (request.getAssessmentId() != null && !request.getAssessmentId().isBlank()) {
            try {
                Long parsedId = Long.parseLong(request.getAssessmentId().trim());
                exam = examRepository.findById(parsedId).orElse(null);
            } catch (NumberFormatException e) {
                // Non-numeric assessment identifier descriptor
            }
            if (exam == null) {
                String examName = "Assessment " + request.getAssessmentId().trim();
                Exam newExam = new Exam();
                newExam.setName(examName);
                exam = examRepository.save(newExam);
            }
        } else {
            List<Exam> existingExams = examRepository.findAll();
            if (!existingExams.isEmpty()) {
                exam = existingExams.get(0);
            } else {
                Exam defaultExam = new Exam();
                defaultExam.setName("Regular Assessment");
                exam = examRepository.save(defaultExam);
            }
        }

        // 2. Resolve Subject
        Subject subject = null;
        if (request.getSubjectId() != null) {
            subject = subjectRepository.findById(request.getSubjectId()).orElse(null);
        } else if (request.getSubject() != null && !request.getSubject().isBlank()) {
            subject = subjectRepository.findByName(request.getSubject())
                    .orElseGet(() -> {
                        Subject newSub = new Subject();
                        newSub.setName(request.getSubject());
                        return subjectRepository.save(newSub);
                    });
        }

        if (subject == null) {
            List<Subject> existingSubjects = subjectRepository.findAll();
            if (!existingSubjects.isEmpty()) {
                subject = existingSubjects.get(0);
            } else {
                Subject defaultSub = new Subject();
                defaultSub.setName("General");
                subject = subjectRepository.save(defaultSub);
            }
        }

        // 3. Resolve Academic Year
        AcademicYear academicYear = null;
        if (request.getAcademicYearId() != null) {
            academicYear = academicYearRepository.findById(request.getAcademicYearId()).orElse(null);
        }
        if (academicYear == null) {
            academicYear = academicYearRepository.findAll().stream()
                    .filter(y -> Boolean.TRUE.equals(y.getIsCurrent()))
                    .findFirst()
                    .orElse(null);
        }

        Integer semester = request.getSemester() != null ? request.getSemester() : 1;
        ExamType examType = request.getExamType() != null ? request.getExamType() : ExamType.THUONG_XUYEN;
        Integer txIndex = request.getTxIndex();
        BigDecimal maxScore = request.getMaxMarks() != null ? request.getMaxMarks() : BigDecimal.valueOf(10.00);

        List<Marks> savedMarks = new ArrayList<>();
        for (BulkMarksRequest.Record rec : request.getRecords()) {
            if (rec.getStudentId() == null) continue;

            Student student = studentRepository.findById(rec.getStudentId()).orElse(null);
            if (student == null) continue;

            // BẢO MẬT P1: Xác thực giáo viên có thẩm quyền nhập điểm cho môn học này
            schoolAccessPolicy.verifyTeacherCanGradeSubject(auth, student, subject);

            BigDecimal score = rec.getMarksObtained();
            if (score != null) {
                if (score.compareTo(BigDecimal.ZERO) < 0 || score.compareTo(maxScore) > 0) {
                    throw new IllegalArgumentException("Điểm số " + score + " của học sinh "
                            + student.getName() + " không hợp lệ (phải từ 0 đến " + maxScore + ")");
                }
            }

            String lockKey = ("mark_lock_" + student.getId() + "_" + subject.getId() + "_" + semester + "_" + examType + (txIndex != null ? "_" + txIndex : "")).intern();
            synchronized (lockKey) {
                // Tìm con điểm đã tồn tại theo cấu trúc học bạ để upsert
                Marks mark = null;
                if (academicYear != null) {
                    if (examType == ExamType.THUONG_XUYEN && txIndex != null) {
                        mark = marksRepository.findByStudentIdAndSubjectIdAndSemesterAndAcademicYearIdAndExamTypeAndTxIndex(
                                student.getId(), subject.getId(), semester, academicYear.getId(), examType, txIndex)
                                .orElse(null);
                    } else {
                        mark = marksRepository.findByStudentIdAndSubjectIdAndSemesterAndAcademicYearIdAndExamType(
                                student.getId(), subject.getId(), semester, academicYear.getId(), examType)
                                .orElse(null);
                    }
                }

                if (mark == null) {
                    mark = marksRepository.findByStudentIdAndExamIdAndSubjectId(student.getId(), exam.getId(), subject.getId())
                            .orElse(new Marks());
                }

                mark.setStudent(student);
                mark.setExam(exam);
                mark.setSubject(subject);
                mark.setScore(score);
                mark.setMaxScore(maxScore);
                mark.setAcademicYear(academicYear);
                mark.setSemester(semester);
                mark.setExamType(examType);
                mark.setTxIndex(txIndex);
                if (rec.getRemarks() != null && !rec.getRemarks().isBlank()) {
                    mark.setComment(rec.getRemarks());
                }

                savedMarks.add(marksRepository.saveAndFlush(mark));
            }
        }

        return savedMarks;
    }

    public List<StudentMarkResponse> getMarksByStudentId(Long studentId, String currentUsername, boolean isParent, boolean isTeacher) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return getMarksByStudentId(studentId, auth);
    }

    public List<StudentMarkResponse> getMarksByStudentId(Long studentId, Authentication auth) {
        // BẢO MẬT P0: Cưỡng chế phân quyền theo SchoolAccessPolicy, triệt tiêu hoàn toàn BOLA/IDOR
        Student student = schoolAccessPolicy.verifyCanAccessStudent(auth, studentId);

        List<Marks> marksList = marksRepository.findByStudentId(studentId);
        return marksList.stream().map(m -> {
            BigDecimal maxScore = m.getMaxScore() != null ? m.getMaxScore() : BigDecimal.valueOf(10.00);
            EducationLevel level = EducationLevel.PRIMARY;
            if (student.getSchoolClass() != null && student.getSchoolClass().getGrade() != null) {
                level = EducationLevel.fromGrade(student.getSchoolClass().getGrade());
            }
            String grade = MarksCalculationHelper.classifyAcademic(m.getScore(), level);

            return StudentMarkResponse.builder()
                    .id(m.getId())
                    .studentId(student.getId())
                    .studentName(student.getName())
                    .examId(m.getExam() != null ? m.getExam().getId() : null)
                    .examName(m.getExam() != null ? m.getExam().getName() : "N/A")
                    .subjectId(m.getSubject() != null ? m.getSubject().getId() : null)
                    .subject(m.getSubject() != null ? m.getSubject().getName() : "N/A")
                    .marksObtained(m.getScore())
                    .maxMarks(maxScore)
                    .grade(grade)
                    .examType(m.getExamType() != null ? m.getExamType().name() : null)
                    .semester(m.getSemester())
                    .txIndex(m.getTxIndex())
                    .academicYear(m.getAcademicYear() != null ? m.getAcademicYear().getName() : null)
                    .comment(m.getComment())
                    .build();
        }).collect(Collectors.toList());
    }

    public StudentMarkbookResponse getStudentMarkbook(
            Long studentId, Long academicYearId,
            String currentUsername, boolean isParent, boolean isTeacher) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return getStudentMarkbook(studentId, academicYearId, auth);
    }

    /**
     * Xây dựng học bạ đầy đủ cho học sinh trong một năm học.
     * Đảm bảo kiểm soát an ninh đa tầng theo SchoolAccessPolicy (chống BOLA/IDOR).
     */
    public StudentMarkbookResponse getStudentMarkbook(
            Long studentId, Long academicYearId, Authentication auth) {

        // BẢO MẬT P0: Cưỡng chế phân quyền theo SchoolAccessPolicy (STUDENT chỉ xem chính mình)
        Student student = schoolAccessPolicy.verifyCanAccessStudent(auth, studentId);

        // Resolve năm học
        AcademicYear year;
        if (academicYearId != null) {
            year = academicYearRepository.findById(academicYearId)
                    .orElseThrow(() -> new RuntimeException("Năm học không tồn tại: " + academicYearId));
        } else {
            year = academicYearRepository.findAll().stream()
                    .filter(y -> Boolean.TRUE.equals(y.getIsCurrent()))
                    .findFirst()
                    .orElse(null);
        }

        // Lấy tất cả điểm theo năm học
        List<Marks> allMarks = year != null
                ? marksRepository.findByStudentIdAndAcademicYearId(studentId, year.getId())
                : marksRepository.findByStudentId(studentId);

        // Xác định cấp học
        EducationLevel level = EducationLevel.PRIMARY;
        if (student.getSchoolClass() != null && student.getSchoolClass().getGrade() != null) {
            level = EducationLevel.fromGrade(student.getSchoolClass().getGrade());
        }

        // Nhóm điểm theo môn học
        Map<Long, List<Marks>> bySubject = allMarks.stream()
                .filter(m -> m.getSubject() != null)
                .collect(Collectors.groupingBy(m -> m.getSubject().getId()));

        List<SubjectMarkbookDto> subjectDtos = new ArrayList<>();
        for (Map.Entry<Long, List<Marks>> entry : bySubject.entrySet()) {
            Long subjectId2 = entry.getKey();
            List<Marks> subjectMarks = entry.getValue();
            String subjectName = subjectMarks.get(0).getSubject().getName();

            SubjectMarkbookDto dto = SubjectMarkbookDto.builder()
                    .subjectId(subjectId2)
                    .subjectName(subjectName)
                    .semester1(buildSemesterMark(subjectMarks, 1))
                    .semester2(buildSemesterMark(subjectMarks, 2))
                    .build();

            BigDecimal hk1Avg = dto.getSemester1() != null ? dto.getSemester1().getAvg() : null;
            BigDecimal hk2Avg = dto.getSemester2() != null ? dto.getSemester2().getAvg() : null;
            BigDecimal yearAvg = MarksCalculationHelper.calcYearAvg(hk1Avg, hk2Avg);
            dto.setYearAvg(yearAvg);
            dto.setAcademicClassification(MarksCalculationHelper.classifyAcademic(yearAvg, level));

            subjectDtos.add(dto);
        }

        // Tính điểm trung bình chung
        List<BigDecimal> yearAvgs = subjectDtos.stream()
                .map(SubjectMarkbookDto::getYearAvg)
                .collect(Collectors.toList());
        BigDecimal overallAvg = MarksCalculationHelper.calcOverallAvg(yearAvgs);

        String overallClass;
        String honorTitle = null;

        // NGHIỆP VỤ P1: Xếp loại học lực & danh hiệu theo chuẩn Thông tư 22/2021
        String conduct = null; // GV chủ nhiệm sẽ nhập hạnh kiểm khi tổng kết
        if (level == EducationLevel.SECONDARY || level == EducationLevel.HIGH_SCHOOL) {
            // Đếm số môn đánh giá bằng nhận xét (ĐGNX) bị Chưa đạt theo Điều 9 TT 22
            int countFailCommentSubjects = 0;
            for (SubjectMarkbookDto sDto : subjectDtos) {
                if (sDto.getYearAvg() == null) {
                    boolean isFailed = false;
                    if (sDto.getSemester1() != null && sDto.getSemester1().getComments() != null) {
                        isFailed = sDto.getSemester1().getComments().stream()
                                .anyMatch(c -> c != null && (c.toLowerCase().contains("chưa đạt") || c.equalsIgnoreCase("cđ")));
                    }
                    if (sDto.getSemester2() != null && sDto.getSemester2().getComments() != null) {
                        isFailed = isFailed || sDto.getSemester2().getComments().stream()
                                .anyMatch(c -> c != null && (c.toLowerCase().contains("chưa đạt") || c.equalsIgnoreCase("cđ")));
                    }
                    if (isFailed) {
                        countFailCommentSubjects++;
                    }
                }
            }

            overallClass = MarksCalculationHelper.evaluateAcademicResultTT22(yearAvgs, countFailCommentSubjects);
            honorTitle = MarksCalculationHelper.evaluateHonorTitleTT22(overallClass, conduct, yearAvgs);
        } else {
            // Tiểu học (TT 27/2020)
            overallClass = MarksCalculationHelper.classifyAcademic(overallAvg, level);
        }

        String className = student.getSchoolClass() != null
                ? student.getSchoolClass().getName() : null;

        return StudentMarkbookResponse.builder()
                .studentId(student.getId())
                .studentName(student.getName())
                .studentAdmissionNumber(student.getAdmissionNumber())
                .academicYear(year != null ? year.getName() : null)
                .educationLevel(level.name())
                .educationLevelDisplayName(level.getFullName())
                .className(className)
                .schoolName(level.getDefaultSchoolName())
                .subjects(subjectDtos)
                .overallAvg(overallAvg)
                .overallClassification(overallClass)
                .conduct(conduct)
                .honorTitle(honorTitle)
                .build();
    }

    /** Xây SemesterMarkDto cho một môn và một học kỳ. */
    private SemesterMarkDto buildSemesterMark(List<Marks> marks, int semester) {
        List<Marks> semMarks = marks.stream()
                .filter(m -> semester == m.getSemester())
                .collect(Collectors.toList());

        if (semMarks.isEmpty()) return null;

        // TX
        List<BigDecimal> txScores = semMarks.stream()
                .filter(m -> m.getExamType() == ExamType.THUONG_XUYEN)
                .sorted(Comparator.comparingInt(m -> (m.getTxIndex() != null ? m.getTxIndex() : 0)))
                .map(Marks::getScore)
                .collect(Collectors.toList());

        // Nhận xét (cấp 1 lớp 1-3)
        List<String> comments = semMarks.stream()
                .filter(m -> m.getExamType() == ExamType.NHAN_XET && m.getComment() != null)
                .map(Marks::getComment)
                .collect(Collectors.toList());

        BigDecimal gk = semMarks.stream()
                .filter(m -> m.getExamType() == ExamType.GIUA_KY)
                .map(Marks::getScore).findFirst().orElse(null);

        BigDecimal ck = semMarks.stream()
                .filter(m -> m.getExamType() == ExamType.CUOI_KY)
                .map(Marks::getScore).findFirst().orElse(null);

        BigDecimal avg = MarksCalculationHelper.calcSemesterAvg(txScores, gk, ck);

        return SemesterMarkDto.builder()
                .semester(semester)
                .txScores(txScores)
                .gkScore(gk)
                .ckScore(ck)
                .avg(avg)
                .comments(comments.isEmpty() ? null : comments)
                .build();
    }

    /** API P2: Cập nhật một con điểm lẻ */
    @Transactional(rollbackFor = Exception.class)
    public Marks updateSingleMark(Long markId, BigDecimal newScore, String comment, Authentication auth) {
        Marks mark = marksRepository.findById(markId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy con điểm với ID: " + markId));

        schoolAccessPolicy.verifyTeacherCanGradeSubject(auth, mark.getStudent(), mark.getSubject());

        if (newScore != null) {
            BigDecimal max = mark.getMaxScore() != null ? mark.getMaxScore() : BigDecimal.valueOf(10.00);
            if (newScore.compareTo(BigDecimal.ZERO) < 0 || newScore.compareTo(max) > 0) {
                throw new IllegalArgumentException("Điểm số " + newScore + " không hợp lệ (phải từ 0 đến " + max + ")");
            }
            mark.setScore(newScore);
        }

        if (comment != null) {
            mark.setComment(comment);
        }

        return marksRepository.save(mark);
    }

    /** API P2: Xóa con điểm nhập nhầm */
    @Transactional(rollbackFor = Exception.class)
    public void deleteSingleMark(Long markId, Authentication auth) {
        Marks mark = marksRepository.findById(markId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy con điểm với ID: " + markId));

        schoolAccessPolicy.verifyTeacherCanGradeSubject(auth, mark.getStudent(), mark.getSubject());

        marksRepository.delete(mark);
    }
}
