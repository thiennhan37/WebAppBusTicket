package com.example.BusTicket.configuration.WebSocket;

import com.example.BusTicket.dto.JwtObject.JwtInfo;
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
public class WebSocketAuthChannelInterceptor
        implements ChannelInterceptor {

    private final JwtService jwtService;

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
            String token = (String) accessor.getSessionAttributes().get("token");

            if (token == null || token.isBlank()) {
                throw new RuntimeException("Missing JWT");
            }
            String userId = null;
            String role = null;
            try {
                Jwt jwt = jwtService.decode(token);
                List<SimpleGrantedAuthority> authorities =
                        List.of(new SimpleGrantedAuthority(
                                        "ROLE_" + jwt.getClaimAsString("role")));

                accessor.setUser(new JwtAuthenticationToken(jwt, authorities));
            } catch (JOSEException | ParseException e) {
                throw new RuntimeException(e);
            }
        }

        return message;
    }
}
