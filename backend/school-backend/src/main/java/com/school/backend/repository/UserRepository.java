package com.school.backend.repository;

import com.school.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);

    @Modifying
    @Transactional
    @Query("UPDATE User u SET u.failedAttempts = u.failedAttempts + 1 WHERE u.username = :username")
    int incrementFailedAttempts(@Param("username") String username);

    @Modifying
    @Transactional
    @Query("UPDATE User u SET u.failedAttempts = 0, u.lockTime = NULL WHERE u.username = :username")
    int resetLockout(@Param("username") String username);

    @Modifying
    @Transactional
    @Query("UPDATE User u SET u.lockTime = :lockTime WHERE u.username = :username")
    int lockUser(@Param("username") String username, @Param("lockTime") LocalDateTime lockTime);
}
