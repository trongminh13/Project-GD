package com.school.backend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.school.backend.payload.request.LoginRequest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.hamcrest.Matchers.hasItem;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
public class StudentAuthIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @DisplayName("TC-AUTH-STU-01: student01 (Cấp 1 Tiểu học) logs in and gets PRIMARY profile")
    void testStudent01LoginAndProfile() throws Exception {
        LoginRequest req = new LoginRequest();
        req.setUsername("student01");
        req.setPassword("student123");

        MvcResult result = mockMvc.perform(post("/api/auth/signin")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.username").value("student01"))
                .andExpect(jsonPath("$.roles", hasItem("STUDENT")))
                .andReturn();

        String token = objectMapper.readTree(result.getResponse().getContentAsString()).get("token").asText();

        mockMvc.perform(get("/api/student-portal/profile")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.educationLevel").value("PRIMARY"))
                .andExpect(jsonPath("$.educationLevelName").value("Tiểu học"));
    }

    @Test
    @DisplayName("TC-AUTH-STU-02: student02 (Cấp 2 THCS) logs in and gets SECONDARY profile")
    void testStudent02LoginAndProfile() throws Exception {
        LoginRequest req = new LoginRequest();
        req.setUsername("student02");
        req.setPassword("student123");

        MvcResult result = mockMvc.perform(post("/api/auth/signin")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.username").value("student02"))
                .andExpect(jsonPath("$.roles", hasItem("STUDENT")))
                .andReturn();

        String token = objectMapper.readTree(result.getResponse().getContentAsString()).get("token").asText();

        mockMvc.perform(get("/api/student-portal/profile")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.educationLevel").value("SECONDARY"))
                .andExpect(jsonPath("$.educationLevelName").value("THCS"));
    }

    @Test
    @DisplayName("TC-AUTH-STU-03: student03 (Cấp 3 THPT) logs in and gets HIGH_SCHOOL profile")
    void testStudent03LoginAndProfile() throws Exception {
        LoginRequest req = new LoginRequest();
        req.setUsername("student03");
        req.setPassword("student123");

        MvcResult result = mockMvc.perform(post("/api/auth/signin")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.username").value("student03"))
                .andExpect(jsonPath("$.roles", hasItem("STUDENT")))
                .andReturn();

        String token = objectMapper.readTree(result.getResponse().getContentAsString()).get("token").asText();

        mockMvc.perform(get("/api/student-portal/profile")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.educationLevel").value("HIGH_SCHOOL"))
                .andExpect(jsonPath("$.educationLevelName").value("THPT"));
    }

    @Test
    @DisplayName("TC-AUTH-STU-04: Student can log in using admissionNumber STU002")
    void testStudentLoginViaAdmissionNumber() throws Exception {
        LoginRequest req = new LoginRequest();
        req.setUsername("STU002");
        req.setPassword("student123");

        mockMvc.perform(post("/api/auth/signin")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.username").value("student02"))
                .andExpect(jsonPath("$.roles", hasItem("STUDENT")));
    }

    @Test
    @DisplayName("TC-MARKBOOK-STU-01: student01, student02, student03 can fetch their full Vietnamese markbook")
    void testStudentGetMyMarkbook() throws Exception {
        // student02 (THCS)
        LoginRequest req = new LoginRequest();
        req.setUsername("student02");
        req.setPassword("student123");

        MvcResult result = mockMvc.perform(post("/api/auth/signin")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andReturn();

        String token = objectMapper.readTree(result.getResponse().getContentAsString()).get("token").asText();

        mockMvc.perform(get("/api/student-portal/markbook")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.educationLevel").value("SECONDARY"))
                .andExpect(jsonPath("$.studentName").isNotEmpty())
                .andExpect(jsonPath("$.subjects").isArray());

        // student01 (Tiểu học)
        req.setUsername("student01");
        result = mockMvc.perform(post("/api/auth/signin")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andReturn();
        token = objectMapper.readTree(result.getResponse().getContentAsString()).get("token").asText();

        mockMvc.perform(get("/api/student-portal/markbook")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.educationLevel").value("PRIMARY"))
                .andExpect(jsonPath("$.studentName").isNotEmpty());

        // student03 (THPT)
        req.setUsername("student03");
        result = mockMvc.perform(post("/api/auth/signin")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andReturn();
        token = objectMapper.readTree(result.getResponse().getContentAsString()).get("token").asText();

        mockMvc.perform(get("/api/student-portal/markbook")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.educationLevel").value("HIGH_SCHOOL"))
                .andExpect(jsonPath("$.studentName").isNotEmpty());
    }
}
