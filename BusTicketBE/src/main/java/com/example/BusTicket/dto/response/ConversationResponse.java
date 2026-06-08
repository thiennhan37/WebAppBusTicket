package com.example.BusTicket.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ConversationResponse {
    private Integer id;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime lastMessageAt;
    private CustomerInfoResponse customer;
    private String busCompanyId;
    private String busCompanyName;
    private MessageResponse lastMessage;
}
