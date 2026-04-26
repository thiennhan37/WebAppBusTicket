package com.example.BusTicket.controller.customer;

import com.example.BusTicket.dto.request.CustomerRegisterRequest;
import com.example.BusTicket.dto.request.EmailLoginRequest;
import com.example.BusTicket.dto.request.LogoutRequest;
import com.example.BusTicket.dto.request.OtpVerifyRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.CustomerAuthenticationResponse;
import com.example.BusTicket.dto.response.CustomerInfoResponse;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.service.AuthenticationService;
import com.example.BusTicket.service.CustomerAuthService;
import com.nimbusds.jose.JOSEException;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.text.ParseException;

@Slf4j
@RestController
@RequiredArgsConstructor
public class CustomerAuthController {
    private final AuthenticationService authenticationService;
    private final CustomerAuthService customerAuthService;
    @PostMapping("auth/send-otp")
    ApiResponse<Void> sendOtp(@RequestBody EmailLoginRequest request) {
        log.info("in sendOtp controller");
        authenticationService.sendOtp(request.getEmail());
        return ApiResponse.success(null);
    }

    @PostMapping("auth/verify-otp")
    ApiResponse<CustomerAuthenticationResponse> verifyOtp(@RequestBody OtpVerifyRequest request)
            throws JOSEException {
        log.info("in verifyOtp controller");
        CustomerAuthenticationResponse response = authenticationService.verifyOtp(request.getEmail(), request.getOtp());
        return ApiResponse.success(response);
    }

    @PostMapping("auth/logout")
    ApiResponse<Boolean> logout(@RequestBody LogoutRequest request) throws JOSEException, ParseException {
        authenticationService.logout(request);
        log.info(request.getAccessToken() + " " + request.getRefreshToken());
        return ApiResponse.success(true);
    }

    @PostMapping("auth/register")
    public ApiResponse<?> register(@Valid @RequestBody CustomerRegisterRequest request) {
        try {
            CustomerInfoResponse response = customerAuthService.registerCustomer(request);
            return ApiResponse.success(response);
        } catch (RuntimeException e) {
            // Trả về lỗi 400 nếu email/sđt đã tồn tại
            return ApiResponse.error(ErrorCode.INVALID_CUSTOMER_REGISTER);
        }
    }
}
