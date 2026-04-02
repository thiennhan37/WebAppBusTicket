package com.example.BusTicket.entity;

import com.example.BusTicket.dto.general.InfoAccount;
import jakarta.persistence.*;
import lombok.Data;


import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity

public class CompanyUser implements InfoAccount {
    @Id
    private String id;
    private String email, phone, password, fullName;
    private LocalDate dob;
    private String gender, role, status;
    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bus_company_id")
    private BusCompany busCompany;

    @Override
    public String getId(){
        return this.id;
    }
    @Override
    public String getEmail(){
        return this.email;
    }
    @Override
    public String getRole(){
        return this.role;
    }
    @Override
    public String getPassword(){
        return this.password;
    }
    @Override
    public String getStatus(){
        return this.status;
    }
}
