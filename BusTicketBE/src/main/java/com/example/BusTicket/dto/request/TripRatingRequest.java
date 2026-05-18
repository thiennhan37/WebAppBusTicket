package com.example.BusTicket.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class TripRatingRequest {
    @NotNull
    @Min(1)
    @Max(5)
    private Integer serviceQuality;

    @NotNull
    @Min(1)
    @Max(5)
    private Integer punctuality;

    @NotNull
    @Min(1)
    @Max(5)
    private Integer safety;

    @NotNull
    @Min(1)
    @Max(5)
    private Integer cleanliness;
}