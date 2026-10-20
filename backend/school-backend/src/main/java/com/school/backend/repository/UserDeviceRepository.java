package com.school.backend.repository;

import com.school.backend.entity.UserDevice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserDeviceRepository extends JpaRepository<UserDevice, Long> {
    List<UserDevice> findByUserIdAndIsActiveTrue(Long userId);
    List<UserDevice> findByUserIdInAndIsActiveTrue(Collection<Long> userIds);
    Optional<UserDevice> findByDeviceToken(String deviceToken);
    List<UserDevice> findAllByIsActiveTrue();
}
