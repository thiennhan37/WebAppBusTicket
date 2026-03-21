package com.example.BusTicket.entity;

import com.example.BusTicket.dto.JwtObject.JwtAccount;
import jakarta.persistence.*;
import lombok.Data;


import java.time.LocalDate;

@Data
@Entity

public class CompanyUser implements JwtAccount {
    @Id
    private String id;
    private String email, phone, password, fullName;
    private LocalDate dob;
    private String gender, role, status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bus_company_id")
    private BusCompany busCompany;

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
}
