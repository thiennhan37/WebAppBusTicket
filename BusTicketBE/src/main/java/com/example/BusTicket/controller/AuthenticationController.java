package com.example.BusTicket.controller;

import com.example.BusTicket.dto.request.ChangePasswordRequest;
import com.example.BusTicket.dto.request.LogoutRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.RefreshTokenResponse;
import com.example.BusTicket.service.AuthenticationService;
import com.nimbusds.jose.JOSEException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.text.ParseException;

@Slf4j
@RestController
@RequiredArgsConstructor
public class AuthenticationController {
    private final AuthenticationService authenticationService;
    @PostMapping("auth/refresh-token")
    ApiResponse<RefreshTokenResponse> refreshToken(@CookieValue(name = "refreshToken", required = false) String refreshToken)
            throws JOSEException, ParseException {
        log.info("in refreshToken controller");
        RefreshTokenResponse response = authenticationService.refreshToken(refreshToken);
        return ApiResponse.success(response);
    }
    @PostMapping("auth/logout")
    ApiResponse<Boolean> logout(@RequestBody LogoutRequest request, @CookieValue(name = "refreshToken") String refreshToken)
            throws JOSEException, ParseException {
        authenticationService.logout(request, refreshToken);
        return ApiResponse.success(true);
    }
    @PutMapping("auth/change-password")
    ApiResponse<Boolean> changePassword(@RequestBody ChangePasswordRequest request){
        authenticationService.changePassword(request);
        return ApiResponse.success(true);
    }
}
