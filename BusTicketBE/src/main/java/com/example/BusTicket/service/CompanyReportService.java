package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.response.report.*;
import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.BusType;
import com.example.BusTicket.entity.CompanyUser;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.repository.jpa.BusCompanyRepository;
import com.example.BusTicket.repository.jpa.BusTypeRepository;
import com.example.BusTicket.repository.jpa.CompanyUserRepository;
import com.example.BusTicket.repository.jpa.TicketRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoField;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class CompanyReportService {
    private final TicketRepository ticketRepository;
    private final BusCompanyRepository busCompanyRepository;
    private final BusTypeRepository busTypeRepository;
    private final CompanyUserRepository companyUserRepository;


    public CompReportResponse getReport() {
        Jwt jwt = JwtHelper.getJwt();
        String userId = jwt.getSubject();
        CompanyUser companyUser = companyUserRepository.findById(userId)
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = companyUser.getBusCompany();
        if (busCompany == null) {
            throw new MyAppException(ErrorCode.NOT_EXISTED);
        }
        String busCompanyId = busCompany.getId();
        LocalDate now = LocalDate.now();
        LocalDateTime start = now.withDayOfMonth(1).atStartOfDay();
        LocalDateTime end = now.plusMonths(1)
                .withDayOfMonth(1)
                .atStartOfDay();

        return CompReportResponse.builder()
                .revenueReportResp(getRevenueReportResp(busCompanyId, start, end))
//                .ticketReportResp(getTicketReportResp())
//                .tripReportResp(getTripReportResp())
//                .routeReportRespList(getRouteReportResp())
                .staffReportResp(getStaffReportResp(busCompanyId,start,end))
                .build();
    }
    private StaffReportResp getStaffReportResp(String busCompanyId, 
        LocalDateTime start, LocalDateTime end) 
    {
        Long staffCountCurrentMonth =  
            companyUserRepository.countByCreatedInMonth(busCompanyId,start, end);
        Long staffCountLastMonth = 
            companyUserRepository.countByCreatedInMonth(busCompanyId,start.minusMonths(1), end.minusMonths(1));
        return StaffReportResp.builder()
                .staffCountCurrentMonth(staffCountCurrentMonth)
                .staffCountLastMonth(staffCountLastMonth)
                .build();
    }
    private RevenueReportResp getRevenueReportResp(String busCompanyId, 
        LocalDateTime start, LocalDateTime end) 
    {
        Long revenueCurrentMonth = 
            busCompanyRepository.getRevenueInMonth(busCompanyId,start,end);
        Long revenueLastMonth =
                busCompanyRepository.getRevenueInMonth(busCompanyId,start.minusMonths(1),end.minusMonths(1));

        LocalDate now = LocalDate.now();
        LocalDateTime startWeek = now.with(DayOfWeek.MONDAY).atStartOfDay();
        LocalDateTime endWeek = now.plusWeeks(1).with(DayOfWeek.MONDAY).atStartOfDay();
        Map<LocalDate, Long> revenueWeekMap = busCompanyRepository.getRevenueWeekList(busCompanyId, startWeek, endWeek)
                .stream().collect(Collectors.toMap(
                        RevenueByDate::getDate,
                        RevenueByDate::getRevenue
                ));
        List<Long> revenueWeekList = new ArrayList<>();
        for(int i = 0; i <= 6; i++){
            LocalDate date = startWeek.toLocalDate().plusDays(i);
            revenueWeekList.add(revenueWeekMap.getOrDefault(date, 0L));
        }
        return RevenueReportResp.builder()
        .revenueCurrentMonth(revenueCurrentMonth)
        .revenueLastMonth(revenueLastMonth)
        .revenueWeekList(revenueWeekList)
        .build();
    }

    private TicketReportResp getTicketReportResp(String busCompanyId, 
        LocalDateTime start, LocalDateTime end) 
    {
        List<Object[]> ticketCount = ticketRepository.countByStatusInMonth(busCompanyId, start, end);
        Map<String, Long> ticketMap = new HashMap<>();
        for(Object[] x : ticketCount){
            ticketMap.put(x[0].toString(), Long.valueOf(x[1].toString()));
        }
        // Long ticketSoldCurrentMonth = 
        //     ticketRepository.countByStatusInMonth(busCompanyId,start,end);
        // Long ticketSoldLastMonth =
        //         ticketRepository.countByStatusInMonth(busCompanyId,start.minusMonths(1),end.minusMonths(1));
        
        return TicketReportResp.builder()
            .ticketCountCurrentMonth(0L)
            .ticketCountLastMonth(0L)
            .paidTicketCount(0L)
            .holdingTicketCount(0L)
            .cancelledTicketCount(0L)
            .expiredTicketCount(0L)
            .appBookedTicketCount(0L)
            .phoneBookedTicketCount(0L)
            .build();
    }
    private TripReportResp getTripReportResp(String busCompanyId, 
        LocalDateTime start, LocalDateTime end) 
    {
        return TripReportResp.builder()
//                .activeTripCount()
//                .nextScheduledTripList()
            .build();
    }
    private RouteReportResp getRouteReportResp() {
        return RouteReportResp.builder()
//                .route()
//                .ticketCount()
                .build();
   }
}
