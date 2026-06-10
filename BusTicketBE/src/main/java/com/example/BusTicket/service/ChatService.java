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
import com.example.BusTicket.mapper.CustomerMapper;
import com.example.BusTicket.mapper.MessageMapper;
import com.example.BusTicket.repository.jpa.*;
import com.example.BusTicket.specification.ConversationSpecification;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

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
    private final CustomerMapper customerMapper;

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

        // compute unread counts based on previous message in the conversation
        var lastMessageOpt = messageRepository.findTopByConversationIdOrderBySentAtDesc(conversation.getId());
        int lastUnreadCompany = lastMessageOpt.map(m -> m.getUnreadCompanyCount() == null ? 0 : m.getUnreadCompanyCount()).orElse(0);
        int lastUnreadCustomer = lastMessageOpt.map(m -> m.getUnreadCustomerCount() == null ? 0 : m.getUnreadCustomerCount()).orElse(0);

        int unreadCustomerCount = 0;
        int unreadCompanyCount = 0;

        if (RoleEnum.CUSTOMER.name().equals(account.role())) {
            // customer sent a message -> company has one more unread
            unreadCompanyCount = lastUnreadCompany + 1;
            unreadCustomerCount = 0;
        } else {
            // staff/manager sent a message -> customer has one more unread
            unreadCustomerCount = lastUnreadCustomer + 1;
            unreadCompanyCount = 0;
        }

        Message message = Message.builder()
                .conversation(conversation)
                .senderId(account.accountId())
                .senderRole(account.role())
                .content(request.getContent().trim())
                .sentAt(now)
                .unreadCustomerCount(unreadCustomerCount)
                .unreadCompanyCount(unreadCompanyCount)
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
        String role = jwt.getClaimAsString("role");
        String customerId;
        String busCompanyId;

        if (RoleEnum.CUSTOMER.name().equals(role)) {
            if (request.getBusCompanyId() == null || request.getBusCompanyId().isBlank())
                throw new MyAppException(ErrorCode.MISSING_REQUIRED_FIELD);
            customerId = jwt.getSubject();
            busCompanyId = request.getBusCompanyId();
        } else if (RoleEnum.STAFF.name().equals(role) || RoleEnum.MANAGER.name().equals(role)) {
            if (request.getCustomerId() == null || request.getCustomerId().isBlank())
                throw new MyAppException(ErrorCode.MISSING_REQUIRED_FIELD);
            ChatAccount account = getChatAccount(jwt);
            customerId = request.getCustomerId();
            busCompanyId = account.busCompanyId();
        } else {
            throw new MyAppException(ErrorCode.ACCESS_DENIED);
        }

        Conversation conversation = conversationRepository
                .findByCustomerIdAndBusCompanyId(customerId, busCompanyId)
                .orElseGet(() -> createConversation(customerId, busCompanyId));
        return toConversationResponse(conversation);
    }

    @Transactional(readOnly = true)
    public Page<ConversationResponse> getMyConversations(String customerInfo, String companyInfo, Pageable pageable) {
        ChatAccount account = getChatAccount(JwtHelper.getJwt());
        Pageable fixedPageable = PageRequest.of(pageable.getPageNumber(),
                10, Sort.by("lastMessageAt").descending());

        Specification<Conversation> spec = Specification
                .where(ConversationSpecification.containsCompanyInfo(companyInfo))
                .and(ConversationSpecification.containsCustomerInfo(customerInfo));

        // add role-based restriction
        if (RoleEnum.CUSTOMER.name().equals(account.role())) {
            spec = spec.and((root, query, cb) -> cb.equal(root.get("customer").get("id"), account.accountId()));
        } else {
            spec = spec.and((root, query, cb) -> cb.equal(root.get("busCompany").get("id"), account.busCompanyId()));
        }

        Page<Conversation> page = conversationRepository.findAll(spec, fixedPageable);

        List<ConversationResponse> dtoList = page.getContent().stream()
                .map(this::toConversationResponse)
                .collect(Collectors.toList());

        return new PageImpl<>(dtoList, fixedPageable, page.getTotalElements());
    }

    @Transactional
    public Page<MessageResponse> getMessages(Integer conversationId, Pageable pageable) {
        Conversation conversation = conversationRepository.findByIdWithParticipants(conversationId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        ChatAccount account = getChatAccount(JwtHelper.getJwt());
        validateConversationAccess(conversation, account);

        boolean modified = false;
        if (RoleEnum.CUSTOMER.name().equals(account.role())) {
            modified = messageRepository.markCustomerRead(conversationId) > 0;
        } else {
            modified = messageRepository.markCompanyRead(conversationId) > 0;
        }

        if (modified) {
            MessageResponse last = messageRepository.findTopByConversationIdOrderBySentAtDesc(conversationId)
                    .map(messageMapper::toMessageResponse)
                    .orElse(null);
            messagingTemplate.convertAndSend("/topic/conversation/" + conversation.getId() + "/read", last);
            messagingTemplate.convertAndSend("/topic/company/"
                    + conversation.getBusCompany().getId() + "/conversations", last);
        }

        // Use pageable to load a single page of messages from newest -> oldest, then reverse
        int page = Math.max(0, pageable.getPageNumber());
//        int size = pageable.getPageSize() > 0 ? pageable.getPageSize() : 10;
        int size = 10;
        Pageable fixedPageable = PageRequest.of(page, size, Sort.by("sentAt").descending());
        Page<Message> messagePage = messageRepository.findByConversationId(conversationId, fixedPageable);

        // Page.getContent() can return an unmodifiable list in some implementations
        // create a mutable copy first, then reverse in-place to chronological order
        List<Message> messages = new java.util.ArrayList<>(messagePage.getContent());
        java.util.Collections.reverse(messages);

        List<MessageResponse> dtoList = messages.stream()
                .map(messageMapper::toMessageResponse)
                .collect(Collectors.toList());

        return new PageImpl<>(dtoList, fixedPageable, messagePage.getTotalElements());
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
                .customer(customerMapper.toCustomerInfoResponse(conversation.getCustomer()))
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
