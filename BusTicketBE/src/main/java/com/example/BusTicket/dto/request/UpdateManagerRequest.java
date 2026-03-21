package com.example.BusTicket.dto.request;

import com.example.BusTicket.validatior.BirthConstraint;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;

import java.time.LocalDate;

@Getter
public class UpdateManagerRequest {

    private String phone;
    @NotNull(message = "fullName must be not null")
    private String fullName;

    @BirthConstraint(min = 18, message = "birthday is invalid")
    private LocalDate dob;
    private String gender;
    @NotNull(message = "BusCompanyId must be not null")
    private String busCompanyId;
}
