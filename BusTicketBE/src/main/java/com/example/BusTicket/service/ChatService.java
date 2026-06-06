package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.ChatMessageRequest;
import com.example.BusTicket.dto.response.MessageResponse;
import com.example.BusTicket.entity.Conversation;
import com.example.BusTicket.entity.Message;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.repository.jpa.ConversationRepository;
import com.example.BusTicket.repository.jpa.MessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional
public class ChatService {

    private final MessageRepository messageRepository;
    private final ConversationRepository conversationRepository;
    private final SimpMessagingTemplate messagingTemplate;

    public void sendMessage(ChatMessageRequest request) {
        Jwt jwt = JwtHelper.getJwt();
        String senderId = jwt.getSubject();
        Conversation conversation = conversationRepository.findById(request.getConversationId())
                        .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));

        Message message = Message.builder()
                .conversation(conversation)
                .senderId(senderId)
                .content(request.getContent())
                .sentAt(LocalDateTime.now())
                .build();
        messageRepository.save(message);

        MessageResponse response =
                MessageResponse.builder()
                        .id(message.getId())
                        .conversationId(conversation.getId())
                        .senderId(message.getSenderId())
                        .content(message.getContent())
                        .sentAt(message.getSentAt())
                        .build();

        messagingTemplate.convertAndSend(
                "/topic/conversation/" + conversation.getId(),
                response
        );
    }

//    @Transactional(readOnly = true)
//    public Page<MessageResponse> getMessages(String conversationId) {
//        Pagea
//        Page<Message> messages = messageRepository
//                .findByConversationIdOrderBySentAtAsc(conversationId);
//
//        return messages.stream()
//                .map(message -> MessageResponse.builder()
//                        .id(message.getId())
//                        .conversationId(
//                                message.getConversation().getId()
//                        )
//                        .senderId(message.getSenderId())
//                        .content(message.getContent())
//                        .sentAt(message.getSentAt())
//                        .build())
//                .toList();
//    }
}
