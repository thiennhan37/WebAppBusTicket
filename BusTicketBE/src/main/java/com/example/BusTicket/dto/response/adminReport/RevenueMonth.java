package com.example.BusTicket.dto.response.adminReport;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Builder
@Data
@AllArgsConstructor @NoArgsConstructor
public class RevenueMonth {
    private String month;
    private Long amount;
}
