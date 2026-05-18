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
public class AdminResponse {
    @Id
    private String id;
    private String email, fullName, gender, phone, status;
    private LocalDate dob;
    private LocalDateTime createdAt;
}
