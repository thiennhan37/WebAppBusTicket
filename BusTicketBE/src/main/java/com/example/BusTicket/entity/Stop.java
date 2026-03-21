package com.example.BusTicket.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity

public class Stop {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private String id;
    private String name, address;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "province_id")
    private Province province;
}
