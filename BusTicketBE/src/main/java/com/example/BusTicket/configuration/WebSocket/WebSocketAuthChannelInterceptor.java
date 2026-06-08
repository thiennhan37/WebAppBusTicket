package com.example.BusTicket.configuration.WebSocket;

import com.example.BusTicket.dto.JwtObject.JwtInfo;
import com.example.BusTicket.entity.CompanyUser;
import com.example.BusTicket.entity.Conversation;
import com.example.BusTicket.enums.RoleEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.repository.jpa.CompanyUserRepository;
import com.example.BusTicket.repository.jpa.ConversationRepository;
import com.example.BusTicket.service.JwtService;
import com.nimbusds.jose.JOSEException;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.*;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;

import java.text.ParseException;
import java.util.List;

@Component
@RequiredArgsConstructor
// Interceptor này sẽ được gọi trước khi một tin nhắn được gửi đến kênh WebSocket.
// Nó sẽ kiểm tra xem tin nhắn có phải là một kết nối mới (CONNECT) hay không,
// và nếu có, nó sẽ lấy token JWT từ session attributes,
// xác thực token và thiết lập thông tin người dùng vào StompHeaderAccessor để sử dụng trong các phần khác của ứng dụng.
public class WebSocketAuthChannelInterceptor implements ChannelInterceptor {

    private final JwtService jwtService;
    private final ConversationRepository conversationRepository;
    private final CompanyUserRepository companyUserRepository;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {

        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(
                        message,
                        StompHeaderAccessor.class);

        if (accessor == null) {
            return message;
        }

//        Chỉ xử lý khi có lệnh CONNECT, tức là khi một client mới kết nối đến WebSocket.
        if (StompCommand.CONNECT.equals(accessor.getCommand())) {
            String token = accessor.getSessionAttributes() == null
                    ? null
                    : (String) accessor.getSessionAttributes().get("token");

            if (token == null || token.isBlank())  throw new RuntimeException("Missing JWT");

            try {
                Jwt jwt = jwtService.decode(token);
                List<SimpleGrantedAuthority> authorities =
                        List.of(new SimpleGrantedAuthority("ROLE_" + jwt.getClaimAsString("role")));

                accessor.setUser(new JwtAuthenticationToken(jwt, authorities));
            } catch (JOSEException | ParseException e) {
                throw new RuntimeException(e);
            }
        }

        // ...
        if (StompCommand.SUBSCRIBE.equals(accessor.getCommand())) {
            validateSubscription(accessor);
        }
        return message;
    }

    private void validateSubscription(StompHeaderAccessor accessor) {
        // lấy endpoint đích
        String destination = accessor.getDestination();
        if (destination == null) return;

        // kiểm tra loại endpoint
        boolean conversationTopic = destination.startsWith("/topic/conversation/");
        boolean companyTopic = destination.startsWith("/topic/company/");
        if (!conversationTopic && !companyTopic) return;

        if (!(accessor.getUser() instanceof JwtAuthenticationToken jwtAuthenticationToken)) {
            throw new RuntimeException("Missing JWT");
        }

        Jwt jwt = jwtAuthenticationToken.getToken();
        if (conversationTopic) {
            Integer conversationId = parseConversationId(destination);
            Conversation conversation = conversationRepository.findByIdWithParticipants(conversationId)
                    .orElseThrow(() -> new RuntimeException("Conversation not found"));
            validateConversationSubscription(jwt, conversation);
            return;
        }

        validateCompanySubscription(jwt, destination);
    }

    private Integer parseConversationId(String destination) {
        try {
            return Integer.valueOf(destination.substring("/topic/conversation/".length()));
        } catch (NumberFormatException exception) {
            throw new RuntimeException("Invalid conversation topic", exception);
        }
    }

    private void validateConversationSubscription(Jwt jwt, Conversation conversation) {
        String role = jwt.getClaimAsString("role");
        if (RoleEnum.CUSTOMER.name().equals(role)) {
            String customerId = jwt.getSubject();
            if (!conversation.getCustomer().getId().equals(customerId)) {
                throw new MyAppException(ErrorCode.WS_ACCESS_DENIED);
            }
            return;
        }

        if (RoleEnum.STAFF.name().equals(role) || RoleEnum.MANAGER.name().equals(role)) {
            String staffId = jwt.getSubject();
            CompanyUser companyUser = companyUserRepository.findByIdWithCompany(staffId)
                    .orElseThrow(() -> new RuntimeException("Company user not found"));
            if (!conversation.getBusCompany().getId().equals(companyUser.getBusCompany().getId())) {
                throw new MyAppException(ErrorCode.WS_ACCESS_DENIED);
            }
            return;
        }
        throw new MyAppException(ErrorCode.WS_ACCESS_DENIED);
    }

    private void validateCompanySubscription(Jwt jwt, String destination) {
        String companyTopicPrefix = "/topic/company/";
        String conversationsSuffix = "/conversations";
        if (!destination.endsWith(conversationsSuffix)) {
            throw new RuntimeException("Invalid company topic");
        }

        String busCompanyId = destination.substring(
                companyTopicPrefix.length(),
                destination.length() - conversationsSuffix.length()
        );
        String role = jwt.getClaimAsString("role");
        if (!RoleEnum.STAFF.name().equals(role) && !RoleEnum.MANAGER.name().equals(role)) {
            throw new MyAppException(ErrorCode.WS_ACCESS_DENIED);
        }

        CompanyUser companyUser = companyUserRepository.findByIdWithCompany(jwt.getSubject())
                .orElseThrow(() -> new RuntimeException("Company user not found"));
        if (!busCompanyId.equals(companyUser.getBusCompany().getId())) {
            throw new MyAppException(ErrorCode.WS_ACCESS_DENIED);
        }
    }
}
