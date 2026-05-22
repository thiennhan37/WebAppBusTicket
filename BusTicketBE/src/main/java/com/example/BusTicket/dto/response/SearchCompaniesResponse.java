package com.example.BusTicket.dto.response;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class SearchCompaniesResponse {
    private String busCompanyName;
    private String busCompanyId;
    private double rating;
}
