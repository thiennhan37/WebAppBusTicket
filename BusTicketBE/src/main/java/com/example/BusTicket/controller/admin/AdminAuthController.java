package com.example.BusTicket.controller.admin;


import com.example.BusTicket.dto.request.LoginRequest;
import com.example.BusTicket.dto.response.*;
import com.example.BusTicket.mapper.AuthenticationMapper;
import com.example.BusTicket.service.AuthenticationService;
import com.nimbusds.jose.JOSEException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
@Slf4j
public class AdminAuthController {
    private final AuthenticationService authenticationService;
    private final AuthenticationMapper authenticationMapper;

    @Value("${jwt.refreshTime}")
    private long refreshTime;

    @PostMapping("auth/login")
    ResponseEntity<ApiResponse<AdminLoginResponse>> loginAdmin(@RequestBody LoginRequest request) throws JOSEException {
        log.info("in login admin Controller ");
        AdminLoginResponse authResponse = authenticationService.loginAdmin(request);

        ResponseCookie cookie = ResponseCookie.from("refreshToken", authResponse.getRefreshToken())
                .httpOnly(true) // ngăn ko cho JS đọc được, ngăn chặn XSS
                .secure(false) // localhost
                .path("/vexedat/auth")
                .maxAge(refreshTime)
                .sameSite("Lax")
                .build();
        authResponse.setRefreshToken(null);
        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, cookie.toString())
                .body(ApiResponse.success(authResponse));
    }


}
