package com.example.BusTicket.dto.response;

import com.example.BusTicket.entity.Ticket;
import com.example.BusTicket.entity.Trip;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor

public class TripSeatResponse {

    private String id;
    private String seat, status;
    private Long price;
    private TicketResponse ticket;

}
