package com.example.BusTicket.dto.response;

import com.example.BusTicket.entity.BusCompany;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginResponse {
    private CompanyUserResponse user;
    private BusCompany company;
    private String accessToken;

}
