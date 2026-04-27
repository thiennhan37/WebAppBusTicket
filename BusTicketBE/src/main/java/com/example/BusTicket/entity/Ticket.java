package com.example.BusTicket.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor @AllArgsConstructor @Builder
@Entity
public class Ticket {
    @Id
    private String id;
    private Long price;
    private String status;
    private LocalDateTime updatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trip_seat_id", referencedColumnName = "id")
    private TripSeat tripSeat;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "arrival_id", referencedColumnName = "id")
    private RouteStop arrival;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "destination_id", referencedColumnName = "id")
    private RouteStop destination;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_order_id", referencedColumnName = "id")
    private BookingOrder bookingOrder;

}
