package com.example.BusTicket.dto.response;

import com.example.BusTicket.entity.BusType;
import com.example.BusTicket.entity.Province;
import com.example.BusTicket.entity.TripSeat;
import jakarta.persistence.Id;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TripResponse {

    private String id;
    private String licensePlate, driver;
    private String status;
    private LocalDateTime departureTime;
    private RouteResponse route;
    private BusType busType;
    private Long price, heldSeats, bookedSeats;
    private List<TicketResponse> historyBooking;
    private List<TripSeatResponse> seatMap;
}
