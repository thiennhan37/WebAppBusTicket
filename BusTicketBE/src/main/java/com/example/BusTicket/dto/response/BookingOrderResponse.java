package com.example.BusTicket.dto.response;

import com.example.BusTicket.entity.CompanyUser;
import com.example.BusTicket.entity.Customer;
import com.example.BusTicket.entity.Trip;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor @AllArgsConstructor @Builder
public class BookingOrderResponse {

    private String id;
    private LocalDateTime createdAt;
    private String customerName,customerPhone, customerEmail;
    private Long totalCost;
    private TripResponse trip;
    private Customer bookingUser;
    private String creatingStaffId;
}
