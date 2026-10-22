package com.school.backend.controller;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
public class WebNetworkEtagTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockUser(username = "admin", authorities = {"ADMIN"})
    @DisplayName("Kiểm tra ETag Header được sinh tự động và trả lời 304 Not Modified khi gửi If-None-Match")
    void testEtagAndNotModifiedResponse() throws Exception {
        // Gửi GET request đầu tiên tới endpoint /api/academic-years
        MvcResult firstResult = mockMvc.perform(get("/api/academic-years"))
                .andExpect(status().isOk())
                .andExpect(header().exists(HttpHeaders.ETAG))
                .andReturn();

        String etag = firstResult.getResponse().getHeader(HttpHeaders.ETAG);
        assertThat(etag).isNotNull().isNotBlank();

        // Gửi GET request thứ 2 kèm If-None-Match bằng ETag vừa nhận
        mockMvc.perform(get("/api/academic-years")
                        .header(HttpHeaders.IF_NONE_MATCH, etag))
                .andExpect(status().isNotModified());
    }
}
