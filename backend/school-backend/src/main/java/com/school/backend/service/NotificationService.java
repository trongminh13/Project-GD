package com.school.backend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.school.backend.entity.*;
import com.school.backend.enums.AudienceType;
import com.school.backend.enums.NotificationType;
import com.school.backend.payload.dto.NotificationDto;
import com.school.backend.payload.request.DeviceTokenRequest;
import com.school.backend.payload.request.SendNotificationRequest;
import com.school.backend.repository.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
public class NotificationService {

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private NotificationRecipientRepository notificationRecipientRepository;

    @Autowired
    private UserDeviceRepository userDeviceRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private SchoolClassRepository schoolClassRepository;

    private final DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private final DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Lấy danh sách thông báo của người dùng kèm trạng thái đã đọc
     */
    @Transactional
    public List<NotificationDto> getMyNotifications(Long userId, String audienceFilter) {
        // Tự động liên kết các thông báo toàn trường hoặc lớp học tương ứng nếu người dùng chưa có bản ghi recipient
        syncMissingNotificationsForUser(userId);

        List<NotificationRecipient> recipients = notificationRecipientRepository.findByUserIdWithNotification(userId);

        return recipients.stream()
                .map(this::mapToDto)
                .filter(dto -> {
                    if (audienceFilter == null || audienceFilter.isBlank() || "Tất cả".equalsIgnoreCase(audienceFilter)) {
                        return true;
                    }
                    return dto.getAudience().equalsIgnoreCase(audienceFilter);
                })
                .collect(Collectors.toList());
    }

    /**
     * Lấy số lượng thông báo chưa đọc
     */
    @Transactional(readOnly = true)
    public long getUnreadCount(Long userId) {
        return notificationRecipientRepository.countByUserIdAndIsReadFalse(userId);
    }

    /**
     * Đánh dấu 1 thông báo đã đọc
     */
    @Transactional
    public boolean markAsRead(Long notificationId, Long userId) {
        Optional<NotificationRecipient> opt = notificationRecipientRepository
                .findByUserIdAndNotification_Id(userId, notificationId);
        if (opt.isPresent()) {
            NotificationRecipient r = opt.get();
            if (!Boolean.TRUE.equals(r.getIsRead())) {
                r.setIsRead(true);
                r.setReadAt(LocalDateTime.now());
                notificationRecipientRepository.save(r);
            }
            return true;
        }
        return false;
    }

    /**
     * Đánh dấu tất cả thông báo đã đọc
     */
    @Transactional
    public int markAllAsRead(Long userId) {
        return notificationRecipientRepository.markAllAsReadForUser(userId);
    }

    /**
     * Đăng ký hoặc cập nhật Device Push Token của thiết bị
     */
    @Transactional
    public UserDevice registerDeviceToken(Long userId, DeviceTokenRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng ID: " + userId));

        Optional<UserDevice> existing = userDeviceRepository.findByDeviceToken(request.getDeviceToken());
        UserDevice device;
        if (existing.isPresent()) {
            device = existing.get();
            device.setUser(user);
            device.setPlatform(request.getPlatform().toUpperCase());
            device.setDeviceName(request.getDeviceName());
            device.setIsActive(true);
            device.setUpdatedAt(LocalDateTime.now());
        } else {
            device = UserDevice.builder()
                    .user(user)
                    .deviceToken(request.getDeviceToken())
                    .platform(request.getPlatform().toUpperCase())
                    .deviceName(request.getDeviceName())
                    .isActive(true)
                    .build();
        }
        return userDeviceRepository.save(device);
    }

    /**
     * Soạn và gửi thông báo mới: Lưu CSDL + Phân phối + Xây dựng payload Push Lock Screen
     */
    @Transactional
    public Notification sendNotification(Long senderId, SendNotificationRequest request) {
        User sender = senderId != null ? userRepository.findById(senderId).orElse(null) : null;
        String senderName = sender != null ? resolveSenderDisplayName(sender) : "Ban Giám Hiệu";

        Notification notification = Notification.builder()
                .title(request.getTitle())
                .body(request.getBody())
                .notificationType(request.getNotificationType() != null ? request.getNotificationType() : NotificationType.ANNOUNCEMENT)
                .audienceType(request.getAudienceType() != null ? request.getAudienceType() : AudienceType.ALL)
                .targetId(request.getTargetId())
                .sender(sender)
                .senderName(senderName)
                .dataPayload(request.getDataPayload())
                .build();

        Notification saved = notificationRepository.save(notification);

        // Phân phối tới người nhận
        List<User> targetUsers = resolveTargetUsers(saved.getAudienceType(), saved.getTargetId());
        List<NotificationRecipient> recipients = targetUsers.stream()
                .map(u -> NotificationRecipient.builder()
                        .notification(saved)
                        .user(u)
                        .isRead(false)
                        .isSent(false)
                        .build())
                .collect(Collectors.toList());

        notificationRecipientRepository.saveAll(recipients);

        // Lấy danh sách device tokens của người nhận để chuẩn bị push notification
        List<Long> targetUserIds = targetUsers.stream().map(User::getId).collect(Collectors.toList());
        List<UserDevice> devices = userDeviceRepository.findByUserIdInAndIsActiveTrue(targetUserIds);

        // Xây dựng và phát FCM Lock Screen Payload cho từng thiết bị
        for (UserDevice dev : devices) {
            String fcmPayload = buildLockScreenFcmPayload(saved, dev.getDeviceToken());
            log.info("[FCM PUSH LOCK-SCREEN] Gửi tới {} ({}) payload: {}", dev.getPlatform(), dev.getDeviceName(), fcmPayload);
        }

        return saved;
    }

    /**
     * Xây dựng cấu trúc FCM HTTP v1 JSON Payload đảm bảo thông báo NỔI LÊN MÀN HÌNH KHÓA trên cả Android và iOS
     */
    public String buildLockScreenFcmPayload(Notification n, String targetToken) {
        try {
            Map<String, Object> message = new HashMap<>();
            message.put("token", targetToken);

            // 1. Khối notification chuẩn chung (Bắt buộc cho hệ điều hành tự vẽ khi app killed)
            Map<String, String> notificationMap = new HashMap<>();
            notificationMap.put("title", n.getTitle());
            notificationMap.put("body", n.getBody());
            message.put("notification", notificationMap);

            // 2. Khối metadata data payload
            Map<String, String> dataMap = new HashMap<>();
            dataMap.put("notificationId", String.valueOf(n.getId()));
            dataMap.put("type", n.getNotificationType().name());
            dataMap.put("audience", resolveAudienceLabel(n));
            dataMap.put("click_action", "FLUTTER_NOTIFICATION_CLICK");
            if (n.getDataPayload() != null) {
                dataMap.put("extra", n.getDataPayload());
            }
            message.put("data", dataMap);

            // 3. Android Lock Screen Optimization (HIGH priority, Channel Importance MAX, Visibility PUBLIC)
            Map<String, Object> android = new HashMap<>();
            android.put("priority", "HIGH");
            android.put("ttl", "86400s");

            Map<String, Object> androidNotification = new HashMap<>();
            androidNotification.put("channel_id", "school_high_importance");
            androidNotification.put("sound", "default");
            androidNotification.put("default_sound", true);
            androidNotification.put("default_vibrate_timings", true);
            androidNotification.put("notification_priority", "PRIORITY_MAX");
            androidNotification.put("visibility", "PUBLIC"); // BẮT BUỘC ĐỂ HIỆN TRÊN MÀN HÌNH KHÓA
            androidNotification.put("click_action", "FLUTTER_NOTIFICATION_CLICK");
            android.put("notification", androidNotification);
            message.put("android", android);

            // 4. iOS APNs Lock Screen Optimization (apns-priority 10, sound default, alert, time-sensitive)
            Map<String, Object> apns = new HashMap<>();
            Map<String, String> apnsHeaders = new HashMap<>();
            apnsHeaders.put("apns-priority", "10"); // BẮT BUỘC: Đánh thức thiết bị tức thì
            apnsHeaders.put("apns-push-type", "alert");
            apns.put("headers", apnsHeaders);

            Map<String, Object> aps = new HashMap<>();
            Map<String, String> alertMap = new HashMap<>();
            alertMap.put("title", n.getTitle());
            alertMap.put("body", n.getBody());
            aps.put("alert", alertMap);
            aps.put("sound", "default"); // BẮT BUỘC: Đánh thức màn hình khóa iOS
            aps.put("badge", 1);
            aps.put("content-available", 1);
            aps.put("interruption-level", "time-sensitive"); // Vượt Focus Mode trên iOS 15+
            apns.put("payload", Collections.singletonMap("aps", aps));
            message.put("apns", apns);

            return objectMapper.writeValueAsString(Collections.singletonMap("message", message));
        } catch (Exception e) {
            log.error("Lỗi khi sinh FCM Lock Screen payload", e);
            return "{}";
        }
    }

    private void syncMissingNotificationsForUser(Long userId) {
        User user = userRepository.findById(userId).orElse(null);
        if (user == null) return;

        List<Notification> allNotices = notificationRepository.findAll();
        Optional<Student> studentOpt = studentRepository.findByUserId(userId);

        for (Notification n : allNotices) {
            boolean shouldReceive = false;
            if (n.getAudienceType() == AudienceType.ALL) {
                shouldReceive = true;
            } else if (studentOpt.isPresent()) {
                Student s = studentOpt.get();
                SchoolClass sc = s.getSchoolClass();
                if (n.getAudienceType() == AudienceType.GRADE && sc != null && sc.getGrade() != null) {
                    if (sc.getGrade().equalsIgnoreCase(n.getTargetId()) || ("Khối " + sc.getGrade()).equalsIgnoreCase(n.getTargetId())) {
                        shouldReceive = true;
                    }
                } else if (n.getAudienceType() == AudienceType.CLASS && sc != null) {
                    String className = sc.getName();
                    if (className != null && (className.equalsIgnoreCase(n.getTargetId()) || sc.getId().toString().equals(n.getTargetId()))) {
                        shouldReceive = true;
                    }
                } else if (n.getAudienceType() == AudienceType.INDIVIDUAL && n.getTargetId() != null) {
                    if (user.getUsername().equalsIgnoreCase(n.getTargetId()) || user.getId().toString().equals(n.getTargetId())) {
                        shouldReceive = true;
                    }
                }
            }

            if (shouldReceive) {
                Optional<NotificationRecipient> existing = notificationRecipientRepository.findByUserIdAndNotification_Id(userId, n.getId());
                if (existing.isEmpty()) {
                    notificationRecipientRepository.save(NotificationRecipient.builder()
                            .notification(n)
                            .user(user)
                            .isRead(false)
                            .isSent(false)
                            .build());
                }
            }
        }
    }

    private List<User> resolveTargetUsers(AudienceType audienceType, String targetId) {
        if (audienceType == AudienceType.ALL) {
            return userRepository.findAll();
        } else if (audienceType == AudienceType.CLASS && targetId != null) {
            return studentRepository.findAll().stream()
                    .filter(s -> s.getSchoolClass() != null &&
                            (s.getSchoolClass().getName().equalsIgnoreCase(targetId) || s.getSchoolClass().getId().toString().equals(targetId)))
                    .map(Student::getUser)
                    .filter(Objects::nonNull)
                    .collect(Collectors.toList());
        } else if (audienceType == AudienceType.GRADE && targetId != null) {
            return studentRepository.findAll().stream()
                    .filter(s -> s.getSchoolClass() != null &&
                            (s.getSchoolClass().getGrade().equalsIgnoreCase(targetId) || ("Khối " + s.getSchoolClass().getGrade()).equalsIgnoreCase(targetId)))
                    .map(Student::getUser)
                    .filter(Objects::nonNull)
                    .collect(Collectors.toList());
        } else if (audienceType == AudienceType.INDIVIDUAL && targetId != null) {
            return userRepository.findByUsername(targetId)
                    .map(Collections::singletonList)
                    .orElse(Collections.emptyList());
        }
        return Collections.emptyList();
    }

    private NotificationDto mapToDto(NotificationRecipient nr) {
        Notification n = nr.getNotification();
        LocalDateTime dt = n.getCreatedAt() != null ? n.getCreatedAt() : LocalDateTime.now();
        return NotificationDto.builder()
                .id(n.getId())
                .title(n.getTitle())
                .content(n.getBody())
                .audience(resolveAudienceLabel(n))
                .date(dt.format(dateFormatter))
                .time(dt.format(timeFormatter))
                .sender(n.getSenderName())
                .isRead(Boolean.TRUE.equals(nr.getIsRead()))
                .type(n.getNotificationType() != null ? n.getNotificationType().name() : "ANNOUNCEMENT")
                .dataPayload(n.getDataPayload())
                .build();
    }

    private String resolveAudienceLabel(Notification n) {
        if (n.getAudienceType() == AudienceType.ALL) return "Toàn trường";
        if (n.getTargetId() != null && !n.getTargetId().isBlank()) return n.getTargetId();
        return "Chung";
    }

    private String resolveSenderDisplayName(User sender) {
        if (sender.getRole() != null) {
            switch (sender.getRole()) {
                case ADMIN: return "Ban Giám Hiệu";
                case TEACHER: return "Giáo viên bộ môn";
                default: return sender.getUsername();
            }
        }
        return "Ban Quản Trị";
    }
}
