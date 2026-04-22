package com.example.BusTicket.entity;

import com.example.BusTicket.dto.general.BusDiagram;


import com.example.BusTicket.dto.general.DiagramConverter;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@Builder @AllArgsConstructor @NoArgsConstructor
public class BusType {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private Long totalSeats;

    @Convert(converter = DiagramConverter.class)
    @Column(columnDefinition = "json") // định dạng object type cho column
    private BusDiagram diagram;

}
