package com.example.BusTicket.dto.response.report;

import lombok.Builder;
import lombok.Data;
import com.example.BusTicket.dto.response.TripResponse;
import com.example.BusTicket.dto.response.RouteResponse;
import java.util.List;
@Data
@Builder
public class RouteReportResp {
    private RouteResponse route;
    private Long ticketCount;
    
} 

