package com.example.BusTicket.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.time.LocalDate;

@Getter

public class CompanyUserUpRequest {

    @NotNull(message =  "CompanyUserId must be not null")
    private String id;
    @NotNull(message =  "BusCompanyId must be not null")
    private String busCompanyId;
    private String phone;
    private String fullName;
    private LocalDate dob;
    private String gender;
    private String status;



}
