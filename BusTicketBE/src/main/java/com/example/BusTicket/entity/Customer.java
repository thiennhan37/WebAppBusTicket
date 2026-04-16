package com.example.BusTicket.entity;

import com.example.BusTicket.dto.general.InfoAccount;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity
@Builder @NoArgsConstructor
@AllArgsConstructor
public class Customer{
    @Id
    private String id;
    private String email, phone, password, fullName;
    private LocalDate dob;
    private String gender, status;
    private LocalDateTime createdAt;

}
