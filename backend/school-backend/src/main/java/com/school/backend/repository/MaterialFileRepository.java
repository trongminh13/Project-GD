package com.school.backend.repository;

import com.school.backend.entity.MaterialFile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MaterialFileRepository extends JpaRepository<MaterialFile, Long> {
    List<MaterialFile> findByMaterialIdOrderByVersionDesc(Long materialId);
}
