package com.example.BusTicket.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor @AllArgsConstructor @Builder
@Entity
public class Payment {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    private String momoOrderId;
    private String status;
    private String type;
    private Long transId;
    private Long parentTransId;
    private Long amount;
    private LocalDateTime updatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_order_id", referencedColumnName = "id")
    private BookingOrder bookingOrder;
}
