package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.CompanyRegister;
import com.example.BusTicket.entity.CompanyUser;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CompanyRegisterRepository extends JpaRepository<CompanyRegister, String>{
    @Query("""
            SELECT 1 FROM CompanyRegister c
            WHERE (c.status = 'PENDING' OR c.status = 'ACCEPTED')
            AND (c.email = :email OR c.hotline = :hotline)
            """
    )
    Integer checkExistsInfo(String email, String hotline);

    Page<CompanyRegister> findAll(Specification<CompanyRegister> specification, Pageable fixedPageable);
}
