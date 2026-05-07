package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.Stop;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StopRepository extends JpaRepository<Stop, Long> {
    List<Stop> findALlByProvinceId(String provinceId);
    List<Stop> findAll(Specification<Stop> specification);
    // spec -> list, spec + pageable -> page
    @Query("""
            SELECT COUNT(st) FROM Stop st
            WHERE st.id IN :stopIdList AND st.province.id = :provinceId
            """)
    int countStopBelongToProvince(List<Long> stopIdList, String provinceId);
}
