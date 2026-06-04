package com.example.BusTicket.service;

import com.example.BusTicket.dto.response.NotificationPayload;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class NotificationSocketService {
    private final SimpMessagingTemplate messagingTemplate;

    public void notifyCustomer(String customerId, String type, String title, String message, Map<String, Object> data) {
        NotificationPayload payload = buildPayload(type, title, message, data);
        messagingTemplate.convertAndSend("/topic/customers/" + customerId, payload);
    }

    public void broadcastToAllCustomers(String type, String title, String message, Map<String, Object> data) {
        NotificationPayload payload = buildPayload(type, title, message, data);
        messagingTemplate.convertAndSend("/topic/customers", payload);
    }

    private NotificationPayload buildPayload(String type, String title, String message, Map<String, Object> data) {
        return NotificationPayload.builder()
                .eventId(UUID.randomUUID().toString())
                .type(type)
                .title(title)
                .message(message)
                .createdAt(Instant.now())
                .data(data)
                .build();
    }
}