package com.example.BusTicket.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;

@Getter
public class UpdatePasswordRequest {

    @Size(min = 6, message = "Password must be at least 6 character")
    @NotNull(message = "password must be not null")
    private String password;
}
