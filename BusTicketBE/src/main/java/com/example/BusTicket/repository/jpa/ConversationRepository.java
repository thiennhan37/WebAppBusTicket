package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.Conversation;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ConversationRepository extends JpaRepository<Conversation, Integer>, JpaSpecificationExecutor<Conversation> {
    @Query("""
        SELECT c
        FROM Conversation c
        JOIN FETCH c.customer customer
        JOIN FETCH c.busCompany busCompany
        WHERE c.id = :id
    """)
    Optional<Conversation> findByIdWithParticipants(@Param("id") Integer id);

    @Query("""
        SELECT c
        FROM Conversation c
        JOIN FETCH c.customer customer
        JOIN FETCH c.busCompany busCompany
        WHERE customer.id = :customerId AND busCompany.id = :busCompanyId
    """)
    Optional<Conversation> findByCustomerIdAndBusCompanyId(@Param("customerId") String customerId,
                                                           @Param("busCompanyId") String busCompanyId);

    @Query("""
        SELECT c
        FROM Conversation c
        JOIN FETCH c.customer customer
        JOIN FETCH c.busCompany busCompany
        WHERE customer.id = :customerId
        ORDER BY c.lastMessageAt DESC, c.createdAt DESC
    """)
    List<Conversation> findAllByCustomerId(@Param("customerId") String customerId);

    @Query("""
        SELECT c
        FROM Conversation c
        JOIN FETCH c.customer customer
        JOIN FETCH c.busCompany busCompany
        WHERE busCompany.id = :busCompanyId
        ORDER BY c.lastMessageAt DESC, c.createdAt DESC
    """)
    List<Conversation> findAllByBusCompanyId(@Param("busCompanyId") String busCompanyId);

    // Use EntityGraph to fetch associations when executing pageable/spec queries to avoid N+1
    @EntityGraph(attributePaths = {"customer", "busCompany"})
    Page<Conversation> findAll(Specification<Conversation> spec, Pageable pageable);
}


