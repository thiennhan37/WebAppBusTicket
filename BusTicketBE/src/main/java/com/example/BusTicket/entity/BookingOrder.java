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
public class BookingOrder {
    @Id
    private String id;
    private LocalDateTime createdAt;
    private String customerName,customerPhone, customerEmail;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trip_id", referencedColumnName = "id")
    private Trip trip;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_user_id", referencedColumnName = "id")
    private Customer bookingUser;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "creating_staff_id", referencedColumnName = "id")
    private CompanyUser creatingStaff;
}
