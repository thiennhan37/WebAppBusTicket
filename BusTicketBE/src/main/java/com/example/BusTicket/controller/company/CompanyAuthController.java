package com.example.BusTicket.controller.company;

import com.example.BusTicket.dto.request.CompanyRegisterRequest;
import com.example.BusTicket.dto.request.LoginRequest;
import com.example.BusTicket.dto.request.LogoutRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.AuthenticationResponse;
import com.example.BusTicket.dto.response.LogoutResponse;
import com.example.BusTicket.entity.CompanyRegister;
import com.example.BusTicket.enums.AccountType;
import com.example.BusTicket.mapper.AuthenticationMapper;
import com.example.BusTicket.service.AuthenticationService;
import com.nimbusds.jose.JOSEException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.text.ParseException;

@Slf4j
@RestController
@RequiredArgsConstructor
public class CompanyAuthController {
    private final AuthenticationService authenticationService;
    private final AuthenticationMapper authenticationMapper;
    @PostMapping("nhaxe/auth/login")
    ResponseEntity<ApiResponse<LogoutResponse>> login(@RequestBody LoginRequest request) throws JOSEException{
        log.info("in loginController ");
        AuthenticationResponse authResponse = authenticationService.login(AccountType.COMPANY, request);

        ResponseCookie cookie = ResponseCookie.from("refreshToken", authResponse.getRefreshToken())
                .httpOnly(true) // ngăn ko cho JS đọc được, ngăn chặn XSS
                .secure(false) // localhost
                .path("/vexedat/auth")
                .maxAge(60 * 60)
                .sameSite("Lax")
                .build();
        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, cookie.toString())
                .body(ApiResponse.success(authenticationMapper.toLogoutResponse(authResponse)));
    }
    @PostMapping("nhaxe/auth/register")
    ApiResponse<CompanyRegister> register(@RequestBody CompanyRegisterRequest request) throws JOSEException, ParseException {
        return ApiResponse.success(authenticationService.registerCompany(request));
    }
}
