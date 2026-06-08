package com.example.BusTicket.controller.webSocket;

import com.example.BusTicket.dto.request.ChatMessageRequest;
import com.example.BusTicket.dto.response.MessageResponse;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Controller;

import java.security.Principal;

// controller annotation  để đánh dấu đây là một controller xử lý WebSocket
@Controller
@RequiredArgsConstructor
public class ChatWebSocketController {

    private final ChatService chatService;

    @MessageMapping("/chat.send")
    public MessageResponse sendMessage(ChatMessageRequest request, Principal principal) {
        if (!(principal instanceof JwtAuthenticationToken jwtAuthenticationToken)) {
            throw new MyAppException(ErrorCode.UNAUTHENTICATED);
        }
        return chatService.sendMessage(request, jwtAuthenticationToken.getToken());
    }
}
