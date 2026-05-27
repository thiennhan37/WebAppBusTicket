package com.example.BusTicket.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;

import java.time.Instant;
import java.util.Map;

@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public record NotificationPayload(
        String eventId,
        String type,
        String title,
        String message,
        Instant createdAt,
        Map<String, Object> data
) {
}