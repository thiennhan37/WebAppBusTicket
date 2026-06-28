package com.example.BusTicket.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class BusCompanyResponse {
    private String id;
    private String CompanyName;
    private String email;
    private String hotline;
    private String avatarUrl;
    private Double avgStars;
    private Long ratingCount;
}