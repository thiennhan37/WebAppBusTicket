package com.example.BusTicket.controller;

import com.example.BusTicket.dto.request.*;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.AuthenticationResponse;
import com.example.BusTicket.dto.response.CustomerAuthenticationResponse;
import com.example.BusTicket.dto.response.RefreshTokenResponse;
import com.example.BusTicket.enums.AccountType;
import com.example.BusTicket.service.AuthenticationService;
import com.nimbusds.jose.JOSEException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.text.ParseException;

@Slf4j
@RestController
@RequiredArgsConstructor
public class AuthenticationController {
    private final AuthenticationService authenticationService;
    @PostMapping("auth/refresh-token")
    ApiResponse<RefreshTokenResponse> refreshToken(@RequestBody RefreshTokenRequest request)
            throws JOSEException, ParseException {
        log.info("in refreshToken controller");
        RefreshTokenResponse response = authenticationService.refreshToken(request);
        return ApiResponse.success(response);
    }
    @PostMapping("auth/customer-login")
    ApiResponse<CustomerAuthenticationResponse> customerLogin(@RequestBody EmailLoginRequest request)
            throws JOSEException {
        log.info("in customerLogin controller");
        CustomerAuthenticationResponse response = authenticationService.customerLogin(request.getEmail());
        return ApiResponse.success(response);
    }
}
