package com.school.backend.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.school.backend.entity.Notification;
import com.school.backend.entity.SchoolClass;
import com.school.backend.entity.Student;
import com.school.backend.entity.User;
import com.school.backend.enums.AudienceType;
import com.school.backend.enums.NotificationType;
import com.school.backend.enums.Role;
import com.school.backend.payload.request.DeviceTokenRequest;
import com.school.backend.payload.request.SendNotificationRequest;
import com.school.backend.repository.*;
import com.school.backend.security.jwt.JwtUtils;
import com.school.backend.service.NotificationService;
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

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
public class NotificationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private SchoolClassRepository classRepository;

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private NotificationRecipientRepository recipientRepository;

    @Autowired
    private UserDeviceRepository userDeviceRepository;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    private ObjectMapper objectMapper;

    private User studentUser;
    private User adminUser;
    private Student studentProfile;
    private SchoolClass schoolClass;
    private Notification testNotice;

    @BeforeEach
    void setUp() {
        cleanUp();

        schoolClass = classRepository.findByGradeAndSection("3", "A").orElseGet(() -> {
            SchoolClass sc = new SchoolClass();
            sc.setGrade("3");
            sc.setSection("A");
            return classRepository.save(sc);
        });

        studentUser = new User();
        studentUser.setUsername("STU_NOTIF_TEST");
        studentUser.setPassword(passwordEncoder.encode("Password@123"));
        studentUser.setRole(Role.STUDENT);
        studentUser.setMustChangePassword(false);
        studentUser = userRepository.save(studentUser);

        adminUser = new User();
        adminUser.setUsername("ADM_NOTIF_TEST");
        adminUser.setPassword(passwordEncoder.encode("Password@123"));
        adminUser.setRole(Role.ADMIN);
        adminUser.setMustChangePassword(false);
        adminUser = userRepository.save(adminUser);

        studentProfile = new Student();
        studentProfile.setAdmissionNumber("STU_NOTIF_TEST");
        studentProfile.setName("Học Sinh Test Notif");
        studentProfile.setRollNo("33");
        studentProfile.setSchoolClass(schoolClass);
        studentProfile.setUser(studentUser);
        studentProfile = studentRepository.save(studentProfile);

        testNotice = Notification.builder()
                .title("Thông báo kiểm thử toàn trường")
                .body("Nội dung thông báo kiểm thử")
                .audienceType(AudienceType.ALL)
                .notificationType(NotificationType.ANNOUNCEMENT)
                .sender(adminUser)
                .senderName("Ban Giám Hiệu")
                .build();
        testNotice = notificationRepository.save(testNotice);
    }

    @AfterEach
    void tearDown() {
        cleanUp();
    }

    private void cleanUp() {
        recipientRepository.deleteAll();
        userDeviceRepository.deleteAll();
        notificationRepository.deleteAll();
        studentRepository.findByAdmissionNumber("STU_NOTIF_TEST").ifPresent(studentRepository::delete);
        userRepository.findByUsername("STU_NOTIF_TEST").ifPresent(userRepository::delete);
        userRepository.findByUsername("ADM_NOTIF_TEST").ifPresent(userRepository::delete);
    }

    @Test
    @DisplayName("TC-NOTIF-01: Get my notifications returns list with correct fields and unread count")
    void testGetMyNotifications_ReturnsList() throws Exception {
        String token = jwtUtils.generateTokenFromUsername(studentUser.getUsername());

        mockMvc.perform(get("/api/notifications/my-notifications")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].title").value("Thông báo kiểm thử toàn trường"))
                .andExpect(jsonPath("$[0].isRead").value(false));

        mockMvc.perform(get("/api/notifications/unread-count")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.count").isNumber());
    }

    @Test
    @DisplayName("TC-NOTIF-02: Mark notification as read updates isRead to true")
    void testMarkAsRead_Success() throws Exception {
        String token = jwtUtils.generateTokenFromUsername(studentUser.getUsername());

        // First trigger retrieval so recipient record is created
        mockMvc.perform(get("/api/notifications/my-notifications")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk());

        // Now mark as read
        mockMvc.perform(put("/api/notifications/" + testNotice.getId() + "/read")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        // Verify unread count becomes 0
        mockMvc.perform(get("/api/notifications/unread-count")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.count").value(0));
    }

    @Test
    @DisplayName("TC-NOTIF-03: Register device push token saves token successfully")
    void testRegisterDeviceToken_Success() throws Exception {
        String token = jwtUtils.generateTokenFromUsername(studentUser.getUsername());

        DeviceTokenRequest req = DeviceTokenRequest.builder()
                .deviceToken("fcm_token_sample_abc_123456789")
                .platform("ANDROID")
                .deviceName("Samsung Galaxy S24 Ultra")
                .build();

        mockMvc.perform(post("/api/notifications/device-token")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Đăng ký thiết bị nhận thông báo thành công."));

        assertTrue(userDeviceRepository.findByDeviceToken("fcm_token_sample_abc_123456789").isPresent());
    }

    @Test
    @DisplayName("TC-NOTIF-04: Admin sends notification succeeds and creates recipients")
    void testSendNotification_ByAdmin() throws Exception {
        String adminToken = jwtUtils.generateTokenFromUsername(adminUser.getUsername());

        SendNotificationRequest req = SendNotificationRequest.builder()
                .title("Thông báo khẩn cấp: Nghỉ học do bão")
                .body("Tất cả học sinh nghỉ học ngày mai để phòng chống bão số 5.")
                .audienceType(AudienceType.ALL)
                .notificationType(NotificationType.ANNOUNCEMENT)
                .build();

        mockMvc.perform(post("/api/notifications/send")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.notificationId").isNumber());
    }

    @Test
    @DisplayName("TC-NOTIF-05: Lock Screen FCM v1 Payload adheres strictly to iOS and Android Lock Screen requirements")
    void testFCMv1LockScreenPayload_StructureCompliance() throws Exception {
        String sampleToken = "sample_device_fcm_token_xyz";
        String payloadJson = notificationService.buildLockScreenFcmPayload(testNotice, sampleToken);

        assertNotNull(payloadJson);
        JsonNode root = objectMapper.readTree(payloadJson);
        JsonNode message = root.path("message");

        // 1. Root verification
        assertEquals(sampleToken, message.path("token").asText());
        assertEquals("Thông báo kiểm thử toàn trường", message.path("notification").path("title").asText());
        assertEquals("FLUTTER_NOTIFICATION_CLICK", message.path("data").path("click_action").asText());

        // 2. Android Lock Screen Optimization verification
        JsonNode android = message.path("android");
        assertEquals("HIGH", android.path("priority").asText(), "Android priority MUST be HIGH to break through Doze Mode");
        JsonNode androidNotif = android.path("notification");
        assertEquals("school_high_importance", androidNotif.path("channel_id").asText(), "Channel MUST match high importance channel");
        assertEquals("PUBLIC", androidNotif.path("visibility").asText(), "Visibility MUST be PUBLIC for Lock Screen display");
        assertEquals("PRIORITY_MAX", androidNotif.path("notification_priority").asText());
        assertEquals("default", androidNotif.path("sound").asText());

        // 3. iOS APNs Lock Screen Optimization verification
        JsonNode apns = message.path("apns");
        assertEquals("10", apns.path("headers").path("apns-priority").asText(), "APNs priority MUST be 10 for immediate lock screen wake");
        assertEquals("alert", apns.path("headers").path("apns-push-type").asText());
        JsonNode aps = apns.path("payload").path("aps");
        assertEquals("default", aps.path("sound").asText(), "iOS sound MUST be default for audible lock screen chime");
        assertEquals("time-sensitive", aps.path("interruption-level").asText(), "iOS interruption level MUST be time-sensitive to bypass Focus mode");
    }

    @Test
    @DisplayName("TC-NOTIF-06: Student attempting to send notification is rejected with 403 FORBIDDEN")
    void testSendNotification_ByStudent_Forbidden403() throws Exception {
        String studentToken = jwtUtils.generateTokenFromUsername(studentUser.getUsername());

        SendNotificationRequest req = SendNotificationRequest.builder()
                .title("Thông báo mạo danh")
                .body("Học sinh không có quyền phát thông báo")
                .audienceType(AudienceType.ALL)
                .build();

        mockMvc.perform(post("/api/notifications/send")
                        .header("Authorization", "Bearer " + studentToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("TC-NOTIF-07: Mark all notifications as read updates all recipient records")
    void testMarkAllAsRead_Success() throws Exception {
        String studentToken = jwtUtils.generateTokenFromUsername(studentUser.getUsername());

        // First trigger retrieval so recipient record is created
        mockMvc.perform(get("/api/notifications/my-notifications")
                        .header("Authorization", "Bearer " + studentToken))
                .andExpect(status().isOk());

        // Mark all as read
        mockMvc.perform(put("/api/notifications/read-all")
                        .header("Authorization", "Bearer " + studentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        // Verify unread count is 0
        mockMvc.perform(get("/api/notifications/unread-count")
                        .header("Authorization", "Bearer " + studentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.count").value(0));
    }

    @Test
    @DisplayName("TC-NOTIF-08: Token Handover - Re-registering existing device token updates owner cleanly")
    void testRegisterDeviceToken_DuplicateTokenReassigned() throws Exception {
        String adminToken = jwtUtils.generateTokenFromUsername(adminUser.getUsername());
        String studentToken = jwtUtils.generateTokenFromUsername(studentUser.getUsername());

        String sharedToken = "device_token_shared_between_logins";

        // Step 1: Admin registers device
        DeviceTokenRequest req1 = DeviceTokenRequest.builder()
                .deviceToken(sharedToken)
                .platform("IOS")
                .deviceName("iPhone 15 Pro")
                .build();
        mockMvc.perform(post("/api/notifications/device-token")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req1)))
                .andExpect(status().isOk());

        // Verify owner is Admin
        assertEquals(adminUser.getId(), userDeviceRepository.findByDeviceToken(sharedToken).get().getUser().getId());

        // Step 2: Student logs in on same device and registers token
        DeviceTokenRequest req2 = DeviceTokenRequest.builder()
                .deviceToken(sharedToken)
                .platform("IOS")
                .deviceName("iPhone 15 Pro (Student Login)")
                .build();
        mockMvc.perform(post("/api/notifications/device-token")
                        .header("Authorization", "Bearer " + studentToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req2)))
                .andExpect(status().isOk());

        // Verify owner cleanly transferred to Student
        assertEquals(studentUser.getId(), userDeviceRepository.findByDeviceToken(sharedToken).get().getUser().getId());
    }

    @Test
    @DisplayName("TC-NOTIF-09: NotificationDto serializes both content and body for client dual-compatibility")
    void testNotificationDto_DualContentAndBodySerialization() throws Exception {
        String studentToken = jwtUtils.generateTokenFromUsername(studentUser.getUsername());

        mockMvc.perform(get("/api/notifications/my-notifications")
                        .header("Authorization", "Bearer " + studentToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].content").value("Nội dung thông báo kiểm thử"))
                .andExpect(jsonPath("$[0].body").value("Nội dung thông báo kiểm thử"));
    }
}
