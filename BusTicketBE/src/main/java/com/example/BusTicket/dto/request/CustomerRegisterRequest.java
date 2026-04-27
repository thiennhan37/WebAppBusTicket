package com.example.BusTicket.dto.request;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import java.time.LocalDate;

@Data
public class CustomerRegisterRequest {

    @NotBlank(message = "Họ và tên không được để trống")
    private String fullName;

    @NotBlank(message = "Email không được để trống")
    @Email(message = "Email không đúng định dạng")
    @Pattern(regexp = "^[a-zA-Z0-9._]+@gmail\\.com$", message = "Vui lòng sử dụng Gmail")
    private String email;

    @NotBlank(message = "Mã vùng không được để trống")
    private String idRegion; // Ví dụ: "+84"

    @NotBlank(message = "Số điện thoại không được để trống")
    private String phone;

    @NotNull(message = "Ngày sinh không được để trống")
    @JsonFormat(pattern = "dd/MM/yyyy") // Tự động map chuỗi "17/01/2005" từ Flutter thành LocalDate
    private LocalDate dob;
}