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
public class MessageResponse {
    private Integer id;
    private Integer conversationId;
    private String senderId;
    private String senderRole;
    private String content;
    private Boolean isRead;
    private LocalDateTime sentAt;
}
