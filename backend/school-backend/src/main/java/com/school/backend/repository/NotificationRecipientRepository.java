package com.school.backend.repository;

import com.school.backend.entity.NotificationRecipient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface NotificationRecipientRepository extends JpaRepository<NotificationRecipient, Long> {

    @Query("SELECT nr FROM NotificationRecipient nr JOIN FETCH nr.notification n WHERE nr.user.id = :userId ORDER BY n.createdAt DESC")
    List<NotificationRecipient> findByUserIdWithNotification(@Param("userId") Long userId);

    Optional<NotificationRecipient> findByUserIdAndNotification_Id(Long userId, Long notificationId);

    long countByUserIdAndIsReadFalse(Long userId);

    @Modifying
    @Query("UPDATE NotificationRecipient nr SET nr.isRead = true, nr.readAt = CURRENT_TIMESTAMP WHERE nr.user.id = :userId AND nr.isRead = false")
    int markAllAsReadForUser(@Param("userId") Long userId);
}
