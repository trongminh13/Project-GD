package com.school.backend.service;

import com.school.backend.entity.*;
import com.school.backend.payload.request.MaterialCreateRequest;
import com.school.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
public class MaterialService {

    @Autowired
    private MaterialRepository materialRepository;

    @Autowired
    private MaterialFileRepository materialFileRepository;

    @Autowired
    private MaterialClassRepository materialClassRepository;

    @Autowired
    private TeacherRepository teacherRepository;

    @Autowired
    private SubjectRepository subjectRepository;

    @Autowired
    private SchoolClassRepository schoolClassRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private com.school.backend.security.SchoolAccessPolicy accessPolicy;

    @Transactional
    public Material createMaterial(MaterialCreateRequest req, String teacherUsername) {
        Teacher teacher = teacherRepository.findByUserUsername(teacherUsername)
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ giáo viên không tồn tại."));

        Subject subject = subjectRepository.findById(req.getSubjectId())
                .orElseThrow(() -> new IllegalArgumentException("Môn học không tồn tại."));

        Material m = new Material();
        m.setSubject(subject);
        m.setCreatedByTeacher(teacher);
        m.setTitle(req.getTitle());
        m.setDescription(req.getDescription());
        m.setStatus(req.getStatus() != null ? req.getStatus() : "PUBLISHED");

        Material saved = materialRepository.save(m);

        if (req.getFileName() != null && req.getFileUrl() != null) {
            MaterialFile file = new MaterialFile();
            file.setMaterial(saved);
            file.setFileName(req.getFileName());
            file.setFileUrl(req.getFileUrl());
            file.setVersion(1);
            materialFileRepository.save(file);
        }

        if (req.getTargetClassIds() != null) {
            for (Long classId : req.getTargetClassIds()) {
                schoolClassRepository.findById(classId).ifPresent(sc -> {
                    MaterialClass mc = new MaterialClass();
                    mc.setMaterial(saved);
                    mc.setSchoolClass(sc);
                    materialClassRepository.save(mc);
                });
            }
        }

        return materialRepository.findById(saved.getId()).orElse(saved);
    }

    public List<Material> getMyMaterials(String teacherUsername) {
        Teacher teacher = teacherRepository.findByUserUsername(teacherUsername)
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ giáo viên không tồn tại."));
        return materialRepository.findByCreatedByTeacherIdOrderByCreatedAtDesc(teacher.getId());
    }

    public List<Map<String, Object>> getMaterialsForStudent(String studentUsername) {
        User user = userRepository.findByUsername(studentUsername)
                .orElseThrow(() -> new AccessDeniedException("Người dùng không tồn tại."));
        Student student = studentRepository.findByUserId(user.getId())
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ học sinh không tồn tại."));

        SchoolClass studentClass = enrollmentRepository.findByStudentIdAndAcademicYearIsCurrentTrue(student.getId())
                .map(Enrollment::getSchoolClass)
                .orElse(student.getSchoolClass());

        if (studentClass == null) {
            return Collections.emptyList();
        }

        List<MaterialClass> mcList = materialClassRepository.findBySchoolClassId(studentClass.getId());
        List<Map<String, Object>> result = new ArrayList<>();
        for (MaterialClass mc : mcList) {
            Material m = mc.getMaterial();
            if ("PUBLISHED".equals(m.getStatus())) {
                Map<String, Object> map = new LinkedHashMap<>();
                map.put("id", m.getId());
                map.put("title", m.getTitle());
                map.put("description", m.getDescription());
                map.put("subjectName", m.getSubject().getName());
                map.put("teacherName", m.getCreatedByTeacher().getName());
                map.put("createdAt", m.getCreatedAt());

                List<MaterialFile> files = materialFileRepository.findByMaterialIdOrderByVersionDesc(m.getId());
                List<Map<String, Object>> fileList = new ArrayList<>();
                for (MaterialFile f : files) {
                    Map<String, Object> fMap = new LinkedHashMap<>();
                    fMap.put("id", f.getId());
                    fMap.put("fileName", f.getFileName());
                    fMap.put("fileUrl", f.getFileUrl());
                    fMap.put("pageCount", f.getPageCount());
                    fMap.put("version", f.getVersion());
                    fileList.add(fMap);
                }
                map.put("files", fileList);
                if (!fileList.isEmpty()) {
                    map.put("fileId", fileList.get(0).get("id"));
                    map.put("pageCount", fileList.get(0).get("pageCount"));
                }
                result.add(map);
            }
        }
        return result;
    }

    public org.springframework.http.ResponseEntity<?> downloadFile(Long fileId, org.springframework.security.core.Authentication auth) {
        MaterialFile mf = accessPolicy.verifyCanDownloadMaterialFile(auth, fileId);
        String fileUrl = mf.getFileUrl();
        if (fileUrl != null && (fileUrl.startsWith("http://") || fileUrl.startsWith("https://"))) {
            return org.springframework.http.ResponseEntity.status(org.springframework.http.HttpStatus.FOUND)
                    .location(java.net.URI.create(fileUrl))
                    .build();
        }

        try {
            java.nio.file.Path baseDir = java.nio.file.Paths.get("uploads/materials").toAbsolutePath().normalize();
            java.nio.file.Files.createDirectories(baseDir);
            java.nio.file.Path resolvedPath = baseDir.resolve(mf.getFileName()).normalize();
            if (!resolvedPath.startsWith(baseDir)) {
                throw new SecurityException("Phát hiện hành vi Path Traversal bất hợp pháp.");
            }

            if (!java.nio.file.Files.exists(resolvedPath) || !java.nio.file.Files.isReadable(resolvedPath)) {
                return org.springframework.http.ResponseEntity.notFound().build();
            }

            org.springframework.core.io.Resource resource = new org.springframework.core.io.UrlResource(resolvedPath.toUri());
            return org.springframework.http.ResponseEntity.ok()
                    .contentType(org.springframework.http.MediaType.APPLICATION_OCTET_STREAM)
                    .header(org.springframework.http.HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + mf.getFileName() + "\"")
                    .body(resource);
        } catch (java.io.IOException e) {
            throw new RuntimeException("Không thể đọc tệp tin: " + e.getMessage());
        }
    }
}
