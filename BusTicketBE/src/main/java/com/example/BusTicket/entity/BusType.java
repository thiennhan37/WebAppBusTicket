package com.example.BusTicket.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity

public class BusType {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private String id;
    private String name;
    private int floorCount, rowCount, columnCount;

}
