package com.example.BusTicket.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class BusCompanyRatingResponse {
    private String companyId;
    private Double avgStars;
    private int totalRatings;
}