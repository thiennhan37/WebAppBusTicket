package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.Province;
import com.example.BusTicket.entity.Stop;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StopRepository extends JpaRepository<Stop, Long> {
    List<Stop> findALlByProvinceId(String provinceId);
    Page<Stop> findAll(Specification<Stop> specification, Pageable pageable);
    // spec -> list, spec + pageable -> page
}
