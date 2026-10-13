package com.school.backend.service;

import com.school.backend.entity.Parent;
import com.school.backend.entity.SchoolClass;
import com.school.backend.entity.Student;
import com.school.backend.payload.request.StudentCreateRequest;
import com.school.backend.repository.ParentRepository;
import com.school.backend.repository.SchoolClassRepository;
import com.school.backend.repository.StudentRepository;
import com.school.backend.repository.UserRepository;
import com.school.backend.entity.User;
import com.school.backend.enums.Role;
import org.springframework.security.crypto.password.PasswordEncoder;
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

    @Autowired
    private SchoolClassRepository schoolClassRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

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
        ensureRequiredFields(student);
        return studentRepository.save(student);
    }

    @Transactional
    public Student createStudentFromRequest(StudentCreateRequest req) {
        Student student = new Student();
        student.setName(req.getName() != null && !req.getName().isBlank() ? req.getName() : "Student");
        student.setRollNo(req.getRollNo());
        student.setAdmissionNumber(req.getAdmissionNumber());
        student.setGender(req.getGender() != null ? req.getGender() : "Male");
        student.setDob(req.getDob());
        student.setAddress(req.getAddress());
        student.setPhotoUrl(req.getPhotoUrl());
        student.setAadhaarMasked(req.getAadhaar());

        // Resolve SchoolClass
        if (req.getClassId() != null) {
            schoolClassRepository.findById(req.getClassId()).ifPresent(student::setSchoolClass);
        } else if (req.getClassName() != null && !req.getClassName().isBlank()) {
            List<SchoolClass> classes = schoolClassRepository.findAll();
            for (SchoolClass c : classes) {
                if (req.getClassName().equalsIgnoreCase(c.getGrade()) ||
                    req.getClassName().equalsIgnoreCase(c.getGrade() + "-" + c.getSection()) ||
                    req.getClassName().equalsIgnoreCase(c.getGrade() + " " + c.getSection())) {
                    student.setSchoolClass(c);
                    break;
                }
            }
        }

        // Resolve Parent
        if (req.getParentId() != null) {
            parentRepository.findById(req.getParentId()).ifPresent(student::setParent);
        } else if (req.getMobileNumber() != null && !req.getMobileNumber().isBlank() && !req.getMobileNumber().equals("0")) {
            Parent parent = parentRepository.findByPhone(req.getMobileNumber())
                    .orElseGet(() -> {
                        Parent newP = new Parent();
                        newP.setName(req.getFatherName() != null ? req.getFatherName() : "Parent");
                        newP.setPhone(req.getMobileNumber());
                        return parentRepository.save(newP);
                    });
            student.setParent(parent);
        }

        ensureRequiredFields(student);

        // Auto-create Student User account if not exists
        if (student.getUser() == null) {
            String username = student.getAdmissionNumber();
            String rawPass = (req.getInitialPassword() != null && !req.getInitialPassword().isBlank())
                    ? req.getInitialPassword()
                    : (username + "@School");
            User studentUser = userRepository.findByUsername(username).orElseGet(() -> {
                User newUser = new User();
                newUser.setUsername(username);
                newUser.setPassword(passwordEncoder.encode(rawPass));
                newUser.setRole(Role.STUDENT);
                newUser.setMustChangePassword(true);
                return userRepository.save(newUser);
            });
            student.setUser(studentUser);
        }

        return studentRepository.save(student);
    }

    private void ensureRequiredFields(Student student) {
        if (student.getRollNo() == null || student.getRollNo().isBlank()) {
            student.setRollNo(String.valueOf(studentRepository.count() + 1));
        }
        if (student.getAdmissionNumber() == null || student.getAdmissionNumber().isBlank()) {
            student.setAdmissionNumber("ADM" + (1000 + studentRepository.count() + 1));
        }
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

        Map<String, List<Student>> grouped = allStudents.stream()
                .collect(Collectors.groupingBy(s -> {
                    String name = s.getName() != null ? s.getName().trim().toLowerCase() : "";
                    Long classId = s.getSchoolClass() != null ? s.getSchoolClass().getId() : 0L;
                    return name + "|" + classId;
                }));

        for (Map.Entry<String, List<Student>> entry : grouped.entrySet()) {
            List<Student> duplicates = entry.getValue();
            if (duplicates.size() > 1) {
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
