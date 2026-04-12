package com.example.BusTicket.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Builder

public class BusCompany {
    @Id
    private String id;
    private String hostName, companyName, hotline, avatarUrl, email, policy;
    private LocalDateTime createdAt;

}
