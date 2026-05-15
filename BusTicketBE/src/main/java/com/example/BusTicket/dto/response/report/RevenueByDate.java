package com.example.BusTicket.dto.response.report;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
@Builder
public class RevenueByDate {
    private LocalDate date;
    private Long revenue;
}

