package com.example.BusTicket.controller;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.DeviceTokenRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.service.UserDeviceTokenService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/device-tokens")
@RequiredArgsConstructor
public class DeviceTokenController {
    private final UserDeviceTokenService userDeviceTokenService;

    @PostMapping
    @PreAuthorize("hasRole('CUSTOMER')")
    public ApiResponse<Void> registerDeviceToken(@Valid @RequestBody DeviceTokenRequest request){
        Jwt jwt = JwtHelper.getJwt();
        userDeviceTokenService.saveToken(jwt.getSubject(), request.getToken());
        return ApiResponse.<Void>builder()
                .code(1000)
                .message("Device token registered")
                .build();
    }
}
