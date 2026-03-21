package com.example.BusTicket.dto.request;

import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.validatior.BirthConstraint;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;

import java.time.LocalDate;

@Getter
public class CompanyUserCrRequest {

    @NotNull(message = "Email must be not null")
    private String email;
    private String phone;
    @Size(min = 6, message = "Password must be at least 6 character")
    @NotNull(message = "password must be not null")
    private String password;
    @NotNull(message = "fullName must be not null")
    private String fullName;

    @BirthConstraint(min = 18, message = "birthday is invalid")
    private LocalDate dob;
    private String gender;
    @NotNull(message = "Role must be not null")
    private String  role;
    @NotNull(message = "BusCompanyId must be not null")
    private String busCompanyId;
}
