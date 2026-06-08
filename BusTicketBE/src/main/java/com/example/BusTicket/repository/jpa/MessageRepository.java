package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MessageRepository extends JpaRepository<Message, Integer> {
    List<Message> findByConversationIdOrderBySentAtAsc(Integer conversationId);

    Optional<Message> findTopByConversationIdOrderBySentAtDesc(Integer conversationId);
}


