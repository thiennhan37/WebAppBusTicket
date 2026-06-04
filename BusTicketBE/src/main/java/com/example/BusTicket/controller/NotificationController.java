package com.example.BusTicket.controller;

import com.example.BusTicket.dto.request.NotificationPushRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.service.NotificationSocketService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
public class NotificationController {
    private final NotificationSocketService notificationSocketService;

    @PostMapping("/customers/{customerId}")
    @PreAuthorize("hasAnyRole('ADMIN','MANAGER','STAFF')")
    public ApiResponse<Void> pushToCustomer(@PathVariable String customerId,
                                            @Valid @RequestBody NotificationPushRequest request) {
        notificationSocketService.notifyCustomer(
                customerId,
                request.getType(),
                request.getTitle(),
                request.getMessage(),
                request.getData()
        );

        return ApiResponse.<Void>builder()
                .code(1000)
                .message("Notification pushed to customer")
                .build();
    }

    @PostMapping("/customers/broadcast")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Void> broadcast(@Valid @RequestBody NotificationPushRequest request) {
        notificationSocketService.broadcastToAllCustomers(
                request.getType(),
                request.getTitle(),
                request.getMessage(),
                request.getData()
        );

        return ApiResponse.<Void>builder()
                .code(1000)
                .message("Broadcast notification pushed")
                .build();
    }
}
