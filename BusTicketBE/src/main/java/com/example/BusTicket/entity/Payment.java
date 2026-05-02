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
    private String requestId;
    private String bookingOrderId;
    private String type;
    private Long transId;
    private Long parentTransId;
    private LocalDateTime createdAt;

}
