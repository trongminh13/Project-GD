package com.school.backend.repository;

import com.school.backend.entity.Parent;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface ParentRepository extends JpaRepository<Parent, Long> {
    Optional<Parent> findByPhone(String phone);
    Optional<Parent> findByUserId(Long userId);
}
