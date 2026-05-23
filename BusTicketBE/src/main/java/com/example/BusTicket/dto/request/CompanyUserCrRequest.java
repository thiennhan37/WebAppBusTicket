package com.example.BusTicket.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Builder
@Data
@AllArgsConstructor @NoArgsConstructor
public class CompanyUserCrRequest {

    @NotNull(message = "Email must be not null")
    private String email;
    private String phone;

    private String password;
    @NotNull(message = "fullName must be not null")
    private String fullName;

    private LocalDate dob;
    private String gender;
    @NotNull(message = "Role must be not null")
    private String  role;
    @NotNull(message = "BusCompanyId must be not null")
    private String busCompanyId;
}
