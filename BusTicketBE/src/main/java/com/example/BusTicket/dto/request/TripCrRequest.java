package com.example.BusTicket.dto.request;

import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.BusType;
import com.example.BusTicket.entity.Route;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class TripCrRequest {
    @NotNull
    private String busCompanyId;
    private String licensePlate, driver;
    @NotNull
    private LocalDateTime departureTime;
    @NotNull
    private Long routeId;
    @NotNull
    private Long busTypeId;
    private Long price;

}
