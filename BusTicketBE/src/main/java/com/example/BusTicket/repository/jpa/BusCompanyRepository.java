package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.BusCompany;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BusCompanyRepository extends JpaRepository<BusCompany, String> {
    boolean existsByEmail(String email);
}
