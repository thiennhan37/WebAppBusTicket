package com.example.BusTicket.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.util.Map;

@Data
public class NotificationPushRequest {
    @NotBlank(message = "type is required")
    private String type;

    @NotBlank(message = "title is required")
    private String title;

    @NotBlank(message = "message is required")
    private String message;

    private Map<String, Object> data;
}