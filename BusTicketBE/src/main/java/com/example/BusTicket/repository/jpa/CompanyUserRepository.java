package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.CompanyUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CompanyUserRepository extends JpaRepository<CompanyUser, String> {
    boolean existsByEmail(String email);
    Optional<CompanyUser> findByEmail(String email);
}
