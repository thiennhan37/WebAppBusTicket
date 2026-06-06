package com.example.BusTicket.controller.webSocket;

import com.example.BusTicket.dto.request.ChatMessageRequest;
import com.example.BusTicket.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class ChatWebSocketController {

    private final ChatService chatService;

    @MessageMapping("/chat.send")
    public void sendMessage(ChatMessageRequest request) {
        chatService.sendMessage(request);
    }
}
