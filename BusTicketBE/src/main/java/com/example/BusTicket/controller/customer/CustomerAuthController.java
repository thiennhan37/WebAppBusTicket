package com.example.BusTicket.controller.customer;

import com.example.BusTicket.dto.request.CustomerRegisterRequest;
import com.example.BusTicket.dto.request.EmailLoginRequest;
import com.example.BusTicket.dto.request.LogoutRequest;
import com.example.BusTicket.dto.request.OtpVerifyRequest;
import com.example.BusTicket.dto.request.UpdateCustomerProfileRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.CustomerAuthenticationResponse;
import com.example.BusTicket.dto.response.CustomerInfoResponse;
import com.example.BusTicket.service.AuthenticationService;
import com.example.BusTicket.service.CustomerAuthService;
import com.nimbusds.jose.JOSEException;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

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

    @PostMapping("auth/log-out")
    ApiResponse<Boolean> logout(@RequestBody LogoutRequest request)
            throws JOSEException, ParseException {
        authenticationService.logout(request, request.getRefreshToken());
        return ApiResponse.success(true);
    }


    @PostMapping("/register/init")
    public ApiResponse<?> initiateRegistration(@Valid @RequestBody CustomerRegisterRequest request) {
        customerAuthService.initiateCustomerRegistration(request);
        return ApiResponse.success(true);
    }

    @PostMapping("/register/verify")
    public ApiResponse<?> verifyRegistration(@Valid @RequestBody OtpVerifyRequest request) throws Exception {
        CustomerAuthenticationResponse response = customerAuthService.verifyRegistrationOtp(request.getEmail(), request.getOtp());
        return ApiResponse.success(response);
    }

    @PutMapping("/customer/profile")
    public ApiResponse<CustomerInfoResponse> updateProfile(@Valid @RequestBody UpdateCustomerProfileRequest request) {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        String customerId = authentication != null ? authentication.getName() : null;
        log.info("Updating profile for customer: {}", customerId);
        CustomerInfoResponse response = customerAuthService.updateCustomerProfile(customerId, request);
        return ApiResponse.success(response);
    }
}



