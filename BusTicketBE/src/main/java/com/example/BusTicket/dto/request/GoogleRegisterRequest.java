package com.example.BusTicket.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GoogleRegisterRequest {
    private String idToken;
    private UpdateCustomerProfileRequest profile;
}