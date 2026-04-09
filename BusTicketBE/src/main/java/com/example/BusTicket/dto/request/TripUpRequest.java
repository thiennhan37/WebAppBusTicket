package com.example.BusTicket.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class TripUpRequest {

    private String licensePlate, driver;
    private String status;
    private LocalDateTime departureTime;
    private Long routeId;
    private Long busTypeId;
    private Long price;

}
