package com.example.BusTicket.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@Builder @NoArgsConstructor @AllArgsConstructor
public class Route {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bus_company_id", referencedColumnName = "id")
    private BusCompany busCompany;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "arrival_id", referencedColumnName = "id")
    private Province arrivalProvince;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "destination_id", referencedColumnName = "id")
    private Province destinationProvince;

    private Integer durationMinutes;
}
