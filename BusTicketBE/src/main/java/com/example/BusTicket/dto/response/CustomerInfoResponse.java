package com.example.BusTicket.dto.response;

import com.example.BusTicket.enums.GenderEnum;
import com.example.BusTicket.enums.StatusEnum;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerInfoResponse {
    private String id;
    private String email;
    private String phone;
    private String fullName;
    private LocalDate dob;
    private GenderEnum gender;
    private StatusEnum status;
    private LocalDateTime createdAt;
    private String idRegion;
}