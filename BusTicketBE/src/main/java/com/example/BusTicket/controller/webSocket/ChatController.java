package com.example.BusTicket.controller.webSocket;

import com.example.BusTicket.dto.request.ChatMessageRequest;
import com.example.BusTicket.dto.request.CreateConversationRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.ConversationResponse;
import com.example.BusTicket.dto.response.MessageResponse;
import com.example.BusTicket.service.ChatService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PagedModel;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatController {
    private final ChatService chatService;

    @PostMapping("/conversations")
    public ApiResponse<ConversationResponse> createOrGetConversation(@Valid @RequestBody CreateConversationRequest request) {
        return ApiResponse.success(chatService.createOrGetConversation(request));
    }

    @GetMapping("/conversations")
    public ApiResponse<List<ConversationResponse>> getMyConversations() {
        return ApiResponse.success(chatService.getMyConversations());
    }

    @GetMapping("/conversations/{conversationId}/messages")
    public ApiResponse<PagedModel<MessageResponse>> getMessages(@PathVariable Integer conversationId, Pageable pageable) {
        Page<MessageResponse> page = chatService.getMessages(conversationId, pageable);
        return ApiResponse.success(new PagedModel<>(page));
    }

    @PostMapping("/messages")
    public ApiResponse<MessageResponse> sendMessage(@RequestBody ChatMessageRequest request) {
        return ApiResponse.success(chatService.sendMessage(request));
    }
}
