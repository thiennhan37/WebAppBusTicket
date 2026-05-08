package com.example.BusTicket.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.util.List;

@Getter
public class ChangePasswordRequest {
    @NotNull(message = "Mật khẩu cũ không được để trống")
    private String oldPassword;
    @NotNull(message = "Mật khẩu mới không được để trống")
    private String newPassword;
}
