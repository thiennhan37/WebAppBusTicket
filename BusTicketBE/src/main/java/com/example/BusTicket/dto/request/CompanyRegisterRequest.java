package com.example.BusTicket.dto.request;

import com.example.BusTicket.validatior.BirthConstraint;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.time.LocalDate;

@Getter
public class CompanyRegisterRequest {

    @NotNull(message = "Email must be not null")
    private String email;
    private String hotline;
    private String policy;
    private String name;

}
