package com.example.BusTicket.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.util.List;

@Getter
public class CustomerHoldAndPayRequest {
    @NotNull
    private List<String> tripSeatIdList;
    @NotNull
    private String customerName;
    @NotNull
    private String customerPhone;
    @NotNull
    @Email(message = "Email không hợp lệ")
    private String customerEmail;
}
