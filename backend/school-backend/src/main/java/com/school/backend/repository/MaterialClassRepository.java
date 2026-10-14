package com.school.backend.repository;

import com.school.backend.entity.MaterialClass;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MaterialClassRepository extends JpaRepository<MaterialClass, Long> {
    List<MaterialClass> findBySchoolClassId(Long classId);
    List<MaterialClass> findBySchoolClassIdIn(List<Long> classIds);
    List<MaterialClass> findByMaterialId(Long materialId);
}
