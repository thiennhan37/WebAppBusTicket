package com.example.BusTicket.controller.webSocket;

import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.MessageResponse;
import com.example.BusTicket.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.web.PagedModel;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatController {
    private final ChatService chatService;

//    @GetMapping("/conversations/{conversationId}/messages")
//    public ApiResponse<PagedModel<MessageResponse>> getMessages(@PathVariable String conversationId) {
//        return ApiResponse.<PagedModel<MessageResponse>>builder()
//                .result(chatService.getMessages(conversationId))
//                .build();
//    }
}
