package com.example.BusTicket.dto.response;

import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.entity.RouteStop;
import com.example.BusTicket.entity.TripSeat;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor @AllArgsConstructor @Builder
public class TicketResponse {

    private String id;
    private Long price;
    private String status;
    private String arrivalStop;
    private String destinationStop;
    private LocalDateTime updatedAt;
    private BookingOrderSimple bookingOrder;

}
