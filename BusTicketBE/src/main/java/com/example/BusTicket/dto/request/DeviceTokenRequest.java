package com.example.BusTicket.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class DeviceTokenRequest {
    @NotBlank(message = "FCM token is required")
    @Size(max = 512, message = "FCM token is too long")
    private String token;
}
