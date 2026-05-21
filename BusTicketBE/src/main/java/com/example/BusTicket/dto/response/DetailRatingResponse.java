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
public class DetailRatingResponse {
    private Long id;
    private Integer serviceQuality, punctuality, safety, cleanliness;
    private String customerName, routeName, description;
    private Double averageStars;
    private LocalDateTime createdAt;
}
