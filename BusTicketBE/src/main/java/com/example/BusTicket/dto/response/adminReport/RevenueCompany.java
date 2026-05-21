package com.example.BusTicket.dto.response.adminReport;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Builder
@Data
@AllArgsConstructor @NoArgsConstructor
public class RevenueCompany {
    private String companyName;
    private Long ticketCount;
    private Long amount;
}
