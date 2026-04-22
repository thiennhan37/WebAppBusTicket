package com.example.BusTicket.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TripSimpleResponse {

    private String id;
    private LocalDateTime departureTime;
    private Long totalSeats;
    private Long bookedSeats;
}
