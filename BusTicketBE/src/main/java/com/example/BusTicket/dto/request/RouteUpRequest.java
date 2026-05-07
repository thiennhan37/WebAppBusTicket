package com.example.BusTicket.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.util.List;

@Getter
public class RouteUpRequest {
    private String name;
    private Integer durationMinutes;
    @NotNull
    private List<Long> upStopIdList;
    @NotNull
    private List<Long> downStopIdList;
}
