package com.example.BusTicket.dto.response.companyReport;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RouteReportResp {
    private String routeName;
    private Long ticketCount;
    
} 

