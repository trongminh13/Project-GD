package com.school.backend.controller;

import com.school.backend.entity.Notification;
import com.school.backend.payload.dto.NotificationDto;
import com.school.backend.payload.request.DeviceTokenRequest;
import com.school.backend.payload.request.SendNotificationRequest;
import com.school.backend.security.services.UserDetailsImpl;
import com.school.backend.service.NotificationService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    private Long getCurrentUserId() {
        UserDetailsImpl user = (UserDetailsImpl) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return user.getId();
    }

    /**
     * Lấy danh sách thông báo của người dùng hiện tại (hỗ trợ lọc theo phạm vi)
     */
    @GetMapping("/my-notifications")
    public ResponseEntity<List<NotificationDto>> getMyNotifications(
            @RequestParam(required = false) String audience) {
        Long userId = getCurrentUserId();
        return ResponseEntity.ok(notificationService.getMyNotifications(userId, audience));
    }

    /**
     * Lấy số lượng thông báo chưa đọc (để hiển thị badge)
     */
    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Object>> getUnreadCount() {
        Long userId = getCurrentUserId();
        long count = notificationService.getUnreadCount(userId);
        return ResponseEntity.ok(Collections.singletonMap("count", count));
    }

    /**
     * Đánh dấu 1 thông báo là đã đọc
     */
    @PutMapping("/{id}/read")
    public ResponseEntity<Map<String, Object>> markAsRead(@PathVariable Long id) {
        Long userId = getCurrentUserId();
        boolean updated = notificationService.markAsRead(id, userId);
        return ResponseEntity.ok(Map.of(
                "success", updated,
                "message", updated ? "Đã đánh dấu thông báo đã đọc." : "Không tìm thấy thông báo tương ứng."
        ));
    }

    /**
     * Đánh dấu tất cả thông báo của người dùng là đã đọc
     */
    @PutMapping("/read-all")
    public ResponseEntity<Map<String, Object>> markAllAsRead() {
        Long userId = getCurrentUserId();
        int updatedCount = notificationService.markAllAsRead(userId);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "updatedCount", updatedCount,
                "message", "Đã đánh dấu toàn bộ thông báo đã đọc."
        ));
    }

    /**
     * Đăng ký hoặc làm mới Device Push Token (FCM token) của thiết bị
     */
    @PostMapping("/device-token")
    public ResponseEntity<Map<String, Object>> registerDeviceToken(
            @Valid @RequestBody DeviceTokenRequest request) {
        Long userId = getCurrentUserId();
        notificationService.registerDeviceToken(userId, request);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Đăng ký thiết bị nhận thông báo thành công."
        ));
    }

    /**
     * Soạn và phát thông báo mới (Chỉ dành cho ADMIN hoặc TEACHER)
     */
    @PostMapping("/send")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'TEACHER')")
    public ResponseEntity<Map<String, Object>> sendNotification(
            @Valid @RequestBody SendNotificationRequest request) {
        Long senderId = getCurrentUserId();
        Notification saved = notificationService.sendNotification(senderId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                "success", true,
                "notificationId", saved.getId(),
                "message", "Đã phát thông báo thành công."
        ));
    }
}
