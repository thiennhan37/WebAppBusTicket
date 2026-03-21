package com.example.BusTicket.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Data
@Entity

public class Province {
    @Id
    private String id;
    private String name;


}
