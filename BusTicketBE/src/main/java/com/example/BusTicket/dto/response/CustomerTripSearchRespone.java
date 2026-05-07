package com.example.BusTicket.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CustomerTripSearchRespone {
    private String departureTime;
    private String arrivalTime;
    private String duration;
    private String departureStation;
    private String arrivalStation;
    private int price;
    private int availableSeats;
    private String busCompanyName;
    private String busType;
    private double rating;
    private int reviewCount;
}
