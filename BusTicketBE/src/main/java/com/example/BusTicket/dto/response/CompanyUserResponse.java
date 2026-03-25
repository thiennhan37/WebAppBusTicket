package com.example.BusTicket.dto.response;

import jakarta.persistence.Id;
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
public class CompanyUserResponse {
    @Id
    private String id;
    private String busCompanyId, email, phone, fullName;
    private LocalDate dob;
    private String gender, role, status;
    private LocalDateTime createdAt;
}
