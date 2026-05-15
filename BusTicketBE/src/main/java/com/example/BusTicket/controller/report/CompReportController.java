package com.example.BusTicket.controller.report;

import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.RefreshTokenResponse;
import com.example.BusTicket.dto.response.report.*;
import com.example.BusTicket.service.CompanyReportService;
import com.nimbusds.jose.JOSEException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.text.ParseException;
import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/nhaxe")
public class CompReportController{
    private final CompanyReportService companyReportService;
    @GetMapping("report/staff")
    ApiResponse<StaffReportResp> getStaffReport(){
        return ApiResponse.success(companyReportService.getStaffReportResp());
    }
    @GetMapping("report/revenue")
    ApiResponse<RevenueReportResp> getRevenueReport(){
        return ApiResponse.success(companyReportService.getRevenueReportResp());
    }
    @GetMapping("report/ticket")
    ApiResponse<TicketReportResp> getTicketReport(){
        return ApiResponse.success(companyReportService.getTicketReportResp());
    }
    @GetMapping("report/trip")
    ApiResponse<TripReportResp> getTripReport(){
        return ApiResponse.success(companyReportService.getTripReportResp());
    }
    @GetMapping("report/route")
    ApiResponse<List<RouteReportResp>> getRouteReport(){
        return ApiResponse.success(companyReportService.getRouteReportResp());
    }
}
