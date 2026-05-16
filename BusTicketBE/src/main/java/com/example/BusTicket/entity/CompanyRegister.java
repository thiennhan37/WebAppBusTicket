package com.example.BusTicket.entity;

import com.example.BusTicket.dto.general.InfoAccount;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Fetch;


import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity
@Builder @NoArgsConstructor @AllArgsConstructor
public class CompanyRegister {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private String id;
    private String hostName, companyName, hotline, email, status;
    private LocalDateTime updatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reviewed_by", referencedColumnName = "id")
    private Admin reviewedBy;
}
