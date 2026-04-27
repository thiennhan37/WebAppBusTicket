package com.example.BusTicket.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerAuthenticationResponse {
    private CustomerInfoResponse customerInfo;
    private String accessToken;
    private String refreshToken;
}