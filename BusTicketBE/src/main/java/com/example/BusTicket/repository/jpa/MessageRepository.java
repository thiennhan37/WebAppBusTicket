package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.Message;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MessageRepository extends JpaRepository<Message, Integer> {
    List<Message> findByConversationIdOrderBySentAtAsc(Integer conversationId);

    Optional<Message> findTopByConversationIdOrderBySentAtDesc(Integer conversationId);

    @Modifying
    @Query("""
        UPDATE Message m
        SET m.unreadCustomerCount = 0
        WHERE m.conversation.id = :conversationId
          AND m.unreadCustomerCount > 0
    """)
    int markCustomerRead(Integer conversationId);

    @Modifying
    @Query("""
        UPDATE Message m
        SET m.unreadCompanyCount = 0
        WHERE m.conversation.id = :conversationId
          AND m.unreadCompanyCount > 0
    """)
    int markCompanyRead(Integer conversationId);

    Page<Message> findByConversationId(Integer conversationId, Pageable pageable);
}


