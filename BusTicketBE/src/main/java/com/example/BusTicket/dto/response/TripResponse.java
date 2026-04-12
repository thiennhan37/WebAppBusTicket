package com.example.BusTicket.dto.response;

import com.example.BusTicket.entity.Province;
import jakarta.persistence.Id;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

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
    private String busType;
    private Long price;
}
