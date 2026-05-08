package com.example.BusTicket.dto.request;

import com.example.BusTicket.enums.GenderEnum;
import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.*;
import lombok.Data;

import java.time.LocalDate;

@Data
public class UpdateCustomerProfileRequest {

    @NotBlank(message = "Họ và tên không được để trống")
    @Size(max = 255, message = "Họ và tên không được vượt quá 255 ký tự")
    private String fullName;

    @NotBlank(message = "Số điện thoại không được để trống")
    @Pattern(regexp = "^\\+?[0-9]{7,20}$", message = "Số điện thoại không hợp lệ")
    @Size(max = 20, message = "Số điện thoại không được vượt quá 20 ký tự")
    private String phone;

    @NotBlank(message = "Email không được để trống")
    @Email(message = "Email không đúng định dạng")
    @Pattern(regexp = "^[a-zA-Z0-9._]+@gmail\\.com$", message = "Vui lòng sử dụng Gmail")
    private String email;

    @NotNull(message = "Ngày sinh không được để trống")
    @JsonFormat(pattern = "dd/MM/yyyy")
    @PastOrPresent(message = "Ngày sinh phải có thực hoặc bằng ngày hôm nay")
    private LocalDate dob;

    @NotNull(message = "Giới tính không được để trống")
    private GenderEnum gender;

    @NotBlank(message = "Mã vùng không được để trống")
    @Size(max = 4, message = "Mã vùng không được vượt quá 4 ký tự")
    private String idRegion;
}
