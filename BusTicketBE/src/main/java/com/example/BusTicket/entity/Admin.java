package com.example.BusTicket.entity;

import com.example.BusTicket.dto.general.InfoAccount;
import com.example.BusTicket.enums.AccountType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
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
public class Admin implements InfoAccount {
    @Id
    private String id;
    private String email, password, fullName, gender, phone, status;
    private LocalDate dob;
    private LocalDateTime createdAt;

    @Override
    public String getRole() {
        return AccountType.ADMIN.name();
    }
}
