package com.example.BusTicket.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "trip_rating", uniqueConstraints = {
        @UniqueConstraint(name = "uk_trip_rating_booking_order", columnNames = "booking_order_id")
})
public class TripRating {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer serviceQuality;
    private Integer punctuality;
    private Integer safety;
    private Integer cleanliness;
    private Double averageStars;
    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_order_id", referencedColumnName = "id", nullable = false)
    private BookingOrder bookingOrder;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", referencedColumnName = "id", nullable = false)
    private Customer customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bus_company_id", referencedColumnName = "id", nullable = false)
    private BusCompany busCompany;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;
}