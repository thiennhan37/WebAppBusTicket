package com.example.BusTicket.controller.company;

import com.example.BusTicket.dto.request.CompanyRegisterRequest;
import com.example.BusTicket.dto.request.LoginRequest;
import com.example.BusTicket.dto.request.LogoutRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.AuthenticationResponse;
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
public class CompanyAuthController {
    private final AuthenticationService authenticationService;
    @PostMapping("nhaxe/auth/login")
    ApiResponse<AuthenticationResponse> login(@RequestBody LoginRequest request) throws JOSEException{
        log.info("in loginController ");
        return ApiResponse.success(authenticationService.login(AccountType.COMPANY, request));
    }
    @PostMapping("nhaxe/auth/logout")
    ApiResponse<Boolean> logout(@RequestBody LogoutRequest request) throws JOSEException, ParseException {
        authenticationService.logout(request);
        return ApiResponse.success(true);
    }
//    @PostMapping("nhaxe/auth/register")
//    ApiResponse<Boolean> register(@RequestBody CompanyRegisterRequest request) throws JOSEException, ParseException {
//        authenticationService.logout(request);
//        return ApiResponse.success(true);
//    }
}
