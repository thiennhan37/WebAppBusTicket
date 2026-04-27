package com.example.BusTicket.dto.response;

import com.example.BusTicket.entity.Customer;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor @AllArgsConstructor @Builder
public class BookingOrderSimple {

    private String id;
    private LocalDateTime createdAt;
    private String customerName,customerPhone, customerEmail;
    private Long totalCost;
    private String creatingStaffId;
}
