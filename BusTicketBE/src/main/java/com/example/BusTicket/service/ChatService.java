package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.ChatMessageRequest;
import com.example.BusTicket.dto.request.CreateConversationRequest;
import com.example.BusTicket.dto.response.ConversationResponse;
import com.example.BusTicket.dto.response.MessageResponse;
import com.example.BusTicket.entity.*;
import com.example.BusTicket.enums.RoleEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.MessageMapper;
import com.example.BusTicket.repository.jpa.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class ChatService {
    private final MessageRepository messageRepository;
    private final ConversationRepository conversationRepository;
    private final SimpMessagingTemplate messagingTemplate;
    private final CompanyUserRepository companyUserRepository;
    private final MessageMapper messageMapper;
    private final CustomerRepository customerRepository;
    private final BusCompanyRepository busCompanyRepository;

    private static final String OPEN_STATUS = "OPEN";


    private record ChatAccount(String accountId, String role, String busCompanyId) {
    }
    private ChatAccount getChatAccount(Jwt jwt) {
        String role = jwt.getClaimAsString("role");
        if (RoleEnum.CUSTOMER.name().equals(role)) {
            return new ChatAccount(jwt.getSubject(), role, null);
        }
        if (RoleEnum.STAFF.name().equals(role) || RoleEnum.MANAGER.name().equals(role)) {
            CompanyUser companyUser = companyUserRepository.findByIdWithCompany(jwt.getSubject())
                    .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
            return new ChatAccount(jwt.getSubject(), role, companyUser.getBusCompany().getId());
        }
        throw new MyAppException(ErrorCode.ACCESS_DENIED);
    }

    public MessageResponse sendMessage(ChatMessageRequest request) {
        return sendMessage(request, JwtHelper.getJwt());
    }
    public MessageResponse sendMessage(ChatMessageRequest request, Jwt jwt) {
        if (request.getConversationId() == null || request.getContent() == null || request.getContent().isBlank()) {
            throw new MyAppException(ErrorCode.MISSING_REQUIRED_FIELD);
        }

        Conversation conversation = conversationRepository.findByIdWithParticipants(request.getConversationId())
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        ChatAccount account = getChatAccount(jwt);
        validateConversationAccess(conversation, account);

        LocalDateTime now = LocalDateTime.now();

        Message message = Message.builder()
                .conversation(conversation)
                .senderId(account.accountId())
                .senderRole(account.role())
                .content(request.getContent().trim())
                .sentAt(now)
                .isRead(false)
                .build();
        messageRepository.save(message);

        conversation.setLastMessageAt(now);
        conversationRepository.save(conversation);

        MessageResponse response = messageMapper.toMessageResponse(message);
//       gửi tin nhắn mới đến tất cả người tham gia cuộc trò chuyện
        messagingTemplate.convertAndSend("/topic/conversation/" + conversation.getId(), response);
//      cập nhật danh sách cuộc trò chuyện của công ty nếu người gửi là nhân viên
        messagingTemplate.convertAndSend("/topic/company/"
                + conversation.getBusCompany().getId() + "/conversations", response);
        return response;
    }

    public ConversationResponse createOrGetConversation(CreateConversationRequest request) {
        Jwt jwt = JwtHelper.getJwt();
        if (!RoleEnum.CUSTOMER.name().equals(jwt.getClaimAsString("role")))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);
        if (request.getBusCompanyId() == null || request.getBusCompanyId().isBlank())
            throw new MyAppException(ErrorCode.MISSING_REQUIRED_FIELD);

        String customerId = jwt.getSubject();
        String busCompanyId = request.getBusCompanyId();
        Conversation conversation = conversationRepository
                .findByCustomerIdAndBusCompanyId(customerId, busCompanyId)
                .orElseGet(() -> createConversation(customerId, busCompanyId));
        return toConversationResponse(conversation);
    }

    @Transactional(readOnly = true)
    public List<ConversationResponse> getMyConversations() {
        ChatAccount account = getChatAccount(JwtHelper.getJwt());
        List<Conversation> conversations = RoleEnum.CUSTOMER.name().equals(account.role())
                ? conversationRepository.findAllByCustomerId(account.accountId())
                : conversationRepository.findAllByBusCompanyId(account.busCompanyId());

        return conversations.stream()
                .map(this::toConversationResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<MessageResponse> getMessages(Integer conversationId) {
        Conversation conversation = conversationRepository.findByIdWithParticipants(conversationId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        validateConversationAccess(conversation, getChatAccount(JwtHelper.getJwt()));

        return messageRepository.findByConversationIdOrderBySentAtAsc(conversationId).stream()
                .map(messageMapper::toMessageResponse)
                .toList();
    }

    private void validateConversationAccess(Conversation conversation, ChatAccount account) {
        if (RoleEnum.CUSTOMER.name().equals(account.role())) {
            if (!conversation.getCustomer().getId().equals(account.accountId()))
                throw new MyAppException(ErrorCode.ACCESS_DENIED);

            return;
        }
        if (!conversation.getBusCompany().getId().equals(account.busCompanyId()))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);
    }
    private ConversationResponse toConversationResponse(Conversation conversation) {
        MessageResponse lastMessage = messageRepository.findTopByConversationIdOrderBySentAtDesc(conversation.getId())
                .map(messageMapper::toMessageResponse)
                .orElse(null);

        return ConversationResponse.builder()
                .id(conversation.getId())
                .status(conversation.getStatus())
                .createdAt(conversation.getCreatedAt())
                .lastMessageAt(conversation.getLastMessageAt())
                .customerId(conversation.getCustomer().getId())
                .customerName(conversation.getCustomer().getFullName())
                .busCompanyId(conversation.getBusCompany().getId())
                .busCompanyName(conversation.getBusCompany().getCompanyName())
                .lastMessage(lastMessage)
                .build();
    }

    private Conversation createConversation(String customerId, String busCompanyId) {
        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = busCompanyRepository.findById(busCompanyId)
                .orElseThrow(() -> new MyAppException(ErrorCode.COMPANY_NOT_EXISTED));
        LocalDateTime now = LocalDateTime.now();

        Conversation conversation = Conversation.builder()
                .customer(customer)
                .busCompany(busCompany)
                .status(OPEN_STATUS)
                .createdAt(now)
                .lastMessageAt(now)
                .build();
        return conversationRepository.save(conversation);
    }
}
