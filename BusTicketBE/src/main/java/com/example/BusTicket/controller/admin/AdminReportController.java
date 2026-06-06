package com.example.BusTicket.controller.admin;


import com.example.BusTicket.dto.request.CompanyUpRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.adminReport.AdminCustomerReport;
import com.example.BusTicket.dto.response.adminReport.AdminRevenueReport;
import com.example.BusTicket.dto.response.adminReport.AdminTicketReport;
import com.example.BusTicket.entity.Admin;
import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.CompanyRegister;
import com.example.BusTicket.service.AdminReportService;
import com.example.BusTicket.service.AdminService;
import com.nimbusds.jose.JOSEException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PagedModel;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequiredArgsConstructor
@Slf4j
public class AdminReportController {
    private final AdminReportService adminReportService;

    @GetMapping("/admin-report/revenue")
    ApiResponse<AdminRevenueReport> getRevenueReport(){
        return ApiResponse.success(adminReportService.getRevenueReport());
    }
    @GetMapping("/admin-report/ticket")
    ApiResponse<AdminTicketReport> getTicketReport(){
        return ApiResponse.success(adminReportService.getTicketReport());
    }
    @GetMapping("/admin-report/customer")
    ApiResponse<AdminCustomerReport> getCustomerReport(){
        return ApiResponse.success(adminReportService.getCustomerReport());
    }
    @GetMapping("/admin-report/company")
    ApiResponse<Long> getCompanyReport(){
        return ApiResponse.success(adminReportService.getCompanyReport());
    }


}
