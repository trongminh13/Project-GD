package com.school.backend.repository;

import com.school.backend.entity.FeeStructure;
import com.school.backend.enums.FeeType;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.List;

public interface FeeStructureRepository extends JpaRepository<FeeStructure, Long> {
    List<FeeStructure> findBySchoolClassId(Long classId);
    Optional<FeeStructure> findBySchoolClassIdAndFeeType(Long classId, FeeType feeType);
}
