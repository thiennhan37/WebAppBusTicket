package com.example.BusTicket.dto.response.report;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CompReportResponse {
    private RevenueReportResp revenueReportResp;
    private TicketReportResp ticketReportResp;
    private TripReportResp tripReportResp;
    private List<RouteReportResp> routeReportRespList;
    private StaffReportResp staffReportResp;

}
