package com.example.BusTicket.entity;

import com.example.BusTicket.dto.general.InfoAccount;
import com.example.BusTicket.enums.GenderEnum;
import com.example.BusTicket.enums.StatusEnum;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "customer")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Customer implements InfoAccount {
    @Id
    @Column(name = "ID", length = 50, nullable = false)
    private String id;

    @Column(name = "email", length = 255, nullable = false, unique = true)
    private String email;

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "full_Name", length = 255)
    private String fullName;

    @Column(name = "dob")
    private LocalDate dob;

    @Enumerated(EnumType.STRING)
    @Column(name = "gender")
    private GenderEnum gender;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private StatusEnum status;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    // Thêm field cho InfoAccount
    @Column(name = "role", length = 50)
    private String role = "CUSTOMER";  // Mặc định



    @Column(name = "id_region", length = 4)
    private String idRegion;
    @Override
    public String getId() {
        return this.id;
    }

    @Override
    public String getEmail() {
        return this.email;
    }

    @Override
    public String getRole() {
        return this.role;
    }

    @Override
    public String getPassword() {
        return null;
    }

    @Override
    public String getStatus() {
        return this.status != null ? this.status.name() : null;
    }
}