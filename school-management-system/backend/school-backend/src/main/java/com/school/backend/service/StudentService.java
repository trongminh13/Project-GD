package com.school.backend.service;

import com.school.backend.entity.Parent;
import com.school.backend.entity.Student;
import com.school.backend.repository.StudentRepository;
import com.school.backend.repository.ParentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class StudentService {

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private ParentRepository parentRepository;

    public Page<Student> getAllStudents(Pageable pageable) {
        return studentRepository.findAll(pageable);
    }

    public Optional<Student> getStudentById(Long id) {
        return studentRepository.findById(id);
    }

    public List<Student> getMyWards(String username) {
        Parent parent = parentRepository.findByPhone(username)
                .orElseThrow(() -> new RuntimeException("Parent profile not found for phone: " + username));
        return studentRepository.findByParentId(parent.getId());
    }

    public Student saveStudent(Student student) {
        return studentRepository.save(student);
    }

    public void deleteStudent(Long id) {
        studentRepository.deleteById(id);
    }

    /**
     * Removes duplicate student records. Groups by name + class_id,
     * keeps the record with the lowest ID, and deletes the rest.
     */
    @Transactional
    public int cleanupDuplicates() {
        List<Student> allStudents = studentRepository.findAll();
        int deletedCount = 0;

        // Group by (name + classId) to find duplicates
        Map<String, List<Student>> grouped = allStudents.stream()
                .collect(Collectors.groupingBy(s -> {
                    String name = s.getName() != null ? s.getName().trim().toLowerCase() : "";
                    Long classId = s.getSchoolClass() != null ? s.getSchoolClass().getId() : 0L;
                    return name + "|" + classId;
                }));

        for (Map.Entry<String, List<Student>> entry : grouped.entrySet()) {
            List<Student> duplicates = entry.getValue();
            if (duplicates.size() > 1) {
                // Sort by ID ascending, keep the first (original)
                duplicates.sort(Comparator.comparingLong(Student::getId));
                for (int i = 1; i < duplicates.size(); i++) {
                    studentRepository.deleteById(duplicates.get(i).getId());
                    deletedCount++;
                }
            }
        }

        return deletedCount;
    }
}
