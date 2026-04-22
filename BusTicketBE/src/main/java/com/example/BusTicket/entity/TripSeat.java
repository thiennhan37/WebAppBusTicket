package com.example.BusTicket.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor

public class TripSeat {
    @Id
    private String id;
    private String seat, status;
    private Long price;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trip_id", referencedColumnName = "id")
    private Trip trip;

}
