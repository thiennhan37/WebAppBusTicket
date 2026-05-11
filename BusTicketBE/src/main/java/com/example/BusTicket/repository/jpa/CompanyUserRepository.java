package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.CompanyUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface CompanyUserRepository extends JpaRepository<CompanyUser, String>, JpaSpecificationExecutor<CompanyUser> {
    boolean existsByEmail(String email);
    Optional<CompanyUser> findByEmail(String email);

    @Query("""
        SELECT COUNT(*) FROM CompanyUser user WHERE\s
        createdAt >= :start AND createdAt < :end
        AND user.busCompany.id = :busCompanyId
       \s""")
    Long countByCreatedInMonth(@Param("busCompanyId") String busCompanyId,
                               @Param("start") LocalDateTime start, @Param("end") LocalDateTime end);
    

}
