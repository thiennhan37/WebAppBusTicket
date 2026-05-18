package com.example.BusTicket.dto.response.report;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TicketReportResp {
    private Long ticketCountCurrentMonth;
    private Long ticketCountPreviousMonth;
    // theo tháng
    private Long paidTicketCount;
    private Long holdingTicketCount;
    private Long cancelledTicketCount;
    private Long expiredTicketCount;
    private Long appBookedTicketCount;
    private Long phoneBookedTicketCount;
}

