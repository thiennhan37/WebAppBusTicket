package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.CompanyRegister;
import com.example.BusTicket.entity.CompanyUser;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CompanyRegisterRepository extends JpaRepository<CompanyRegister, String>{
    boolean existsByEmailOrHotline(String email, String hotline);

    Page<CompanyRegister> findAll(Specification<CompanyRegister> specification, Pageable fixedPageable);
}
