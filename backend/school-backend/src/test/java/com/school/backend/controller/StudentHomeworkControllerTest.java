package com.school.backend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.school.backend.entity.SchoolClass;
import com.school.backend.entity.Student;
import com.school.backend.entity.User;
import com.school.backend.enums.Role;
import com.school.backend.payload.request.SubmissionSubmitRequest;
import com.school.backend.repository.SchoolClassRepository;
import com.school.backend.repository.StudentRepository;
import com.school.backend.repository.UserRepository;
import com.school.backend.security.jwt.JwtUtils;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;

import java.util.ArrayList;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
public class StudentHomeworkControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private SchoolClassRepository classRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    private ObjectMapper objectMapper;

    private User studentUser;
    private Student studentProfile;
    private SchoolClass schoolClass;

    @BeforeEach
    void setUp() {
        cleanUp();

        schoolClass = new SchoolClass();
        schoolClass.setGrade("1");
        schoolClass.setSection("A");
        schoolClass = classRepository.save(schoolClass);

        studentUser = new User();
        studentUser.setUsername("STU_HW_TEST");
        studentUser.setPassword(passwordEncoder.encode("Password@123"));
        studentUser.setRole(Role.STUDENT);
        studentUser.setMustChangePassword(false);
        studentUser = userRepository.save(studentUser);

        studentProfile = new Student();
        studentProfile.setAdmissionNumber("STU_HW_TEST");
        studentProfile.setName("Học Sinh Test HW");
        studentProfile.setRollNo("99");
        studentProfile.setSchoolClass(schoolClass);
        studentProfile.setUser(studentUser);
        studentProfile = studentRepository.save(studentProfile);
    }

    @AfterEach
    void tearDown() {
        cleanUp();
    }

    private void cleanUp() {
        studentRepository.findByAdmissionNumber("STU_HW_TEST").ifPresent(studentRepository::delete);
        userRepository.findByUsername("STU_HW_TEST").ifPresent(userRepository::delete);
        if (schoolClass != null && schoolClass.getId() != null) {
            classRepository.deleteById(schoolClass.getId());
            schoolClass = null;
        }
    }

    @Test
    @DisplayName("Submit nonexistent submission returns 404 NOT_FOUND instead of 500 Internal Server Error")
    void testSubmitNonExistentSubmission_Returns404NotFound() throws Exception {
        String token = jwtUtils.generateTokenFromUsername(studentUser.getUsername());

        SubmissionSubmitRequest req = new SubmissionSubmitRequest();
        req.setAnswers(new ArrayList<>());

        mockMvc.perform(post("/api/student-portal/homework/submissions/999999/submit")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.message").value(containsString("Bài làm không tồn tại")));
    }

    @Test
    @DisplayName("Get my homework assignments returns list without error")
    void testGetMyAssignments_ReturnsOk() throws Exception {
        String token = jwtUtils.generateTokenFromUsername(studentUser.getUsername());

        mockMvc.perform(get("/api/student-portal/homework")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk());
    }
}
