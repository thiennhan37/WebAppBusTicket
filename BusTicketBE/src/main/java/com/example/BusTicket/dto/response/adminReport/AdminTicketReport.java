package com.example.BusTicket.dto.response.adminReport;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
public class AdminTicketReport {
    private List<TicketMonth> ticketByMonth;
    private Long totalTicketCurrentMonth;
    private Long canceledTicketCurrentMonth;
}
 