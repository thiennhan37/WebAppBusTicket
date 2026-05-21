package com.example.BusTicket.dto.response.companyReport;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;

@Data
@Builder
public class RevenueByDate {
    private LocalDate date;
    private Long revenue;
}

