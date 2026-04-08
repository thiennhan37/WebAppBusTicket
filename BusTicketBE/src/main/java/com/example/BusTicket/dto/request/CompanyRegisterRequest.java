package com.example.BusTicket.dto.request;

import com.example.BusTicket.validatior.BirthConstraint;
import jakarta.persistence.Id;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
public class CompanyRegisterRequest {

    @NotNull(message = "Email must be not null")
    private String email;
    private String hostName, companyName, hotline;


}
