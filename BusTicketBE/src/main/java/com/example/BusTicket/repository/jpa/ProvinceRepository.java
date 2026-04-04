package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.Province;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProvinceRepository extends JpaRepository<Province, String> {
    List<Province> findByNameContainingIgnoreCase(String keyword, Pageable pageable);

}
