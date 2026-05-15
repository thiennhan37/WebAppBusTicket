package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.response.TripResponse;
import com.example.BusTicket.dto.response.report.*;
import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.BusType;
import com.example.BusTicket.entity.CompanyUser;
import com.example.BusTicket.enums.TicketStatusEnum;
import com.example.BusTicket.enums.TripStatusEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.TripMapper;
import com.example.BusTicket.repository.jpa.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
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
    private final RouteRepository routeRepository;
    private final TripMapper tripMapper;
    private final TripRepository tripRepository;
    private final TicketRepository ticketRepository;
    private final BusCompanyRepository busCompanyRepository;
    private final BusTypeRepository busTypeRepository;
    private final CompanyUserRepository companyUserRepository;

    private BusCompany checkCompany(Jwt jwt){
        String userId = jwt.getSubject();
        CompanyUser companyUser = companyUserRepository.findById(userId)
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = companyUser.getBusCompany();
        if (busCompany == null) {
            throw new MyAppException(ErrorCode.NOT_EXISTED);
        }
        return busCompany;
    }
    public StaffReportResp getStaffReportResp()
    {
        BusCompany busCompany = checkCompany(JwtHelper.getJwt());
        String busCompanyId = busCompany.getId();
        LocalDate now = LocalDate.now();
        LocalDateTime start = now.withDayOfMonth(1).atStartOfDay();
        LocalDateTime end = now.plusMonths(1)
                .withDayOfMonth(1)
                .atStartOfDay();

        Long staffCountCurrentMonth =  
            companyUserRepository.countByCreatedInMonth(busCompanyId,start, end);
        Long staffCountLastMonth = 
            companyUserRepository.countByCreatedInMonth(busCompanyId,start.minusMonths(1), end.minusMonths(1));
        return StaffReportResp.builder()
                .staffCountCurrentMonth(staffCountCurrentMonth)
                .staffCountLastMonth(staffCountLastMonth)
                .build();
    }
    public RevenueReportResp getRevenueReportResp()
    {
        BusCompany busCompany = checkCompany(JwtHelper.getJwt());
        String busCompanyId = busCompany.getId();
        LocalDate now = LocalDate.now();
        LocalDateTime start = now.withDayOfMonth(1).atStartOfDay();
        LocalDateTime end = now.plusMonths(1)
                .withDayOfMonth(1)
                .atStartOfDay();

        Long revenueCurrentMonth = 
            busCompanyRepository.getRevenueInMonth(busCompanyId,start,end);
        Long revenueLastMonth =
                busCompanyRepository.getRevenueInMonth(busCompanyId,start.minusMonths(1),end.minusMonths(1));

        LocalDateTime startWeek = now.with(DayOfWeek.MONDAY).atStartOfDay();
        LocalDateTime endWeek = now.plusWeeks(1).with(DayOfWeek.MONDAY).atStartOfDay();
        List<RevenueByDate> revenueByDateList = busCompanyRepository.getRevenueWeekList(busCompanyId, startWeek, endWeek);
        Map<LocalDate, Long> revenueWeekMap = revenueByDateList.stream()
                .collect(Collectors.toMap(
                        RevenueByDate::getDate,
                        RevenueByDate::getRevenue
                ));
        List<Long> revenueWeekList = new ArrayList<>();
        for(int i = 0; i <= 6; i++){
            LocalDate date = startWeek.toLocalDate().plusDays(i);
            revenueWeekList.add(revenueWeekMap.getOrDefault(date, 0L));
        }
        return RevenueReportResp.builder()
        .revenueCurrentMonth(revenueCurrentMonth != null ? revenueCurrentMonth : 0L)
        .revenueLastMonth(revenueLastMonth != null ? revenueLastMonth : 0L)
        .revenueWeekList(revenueWeekList)
        .build();
    }

    public TicketReportResp getTicketReportResp()
    {
        BusCompany busCompany = checkCompany(JwtHelper.getJwt());
        String busCompanyId = busCompany.getId();
        LocalDate now = LocalDate.now();
        LocalDateTime start = now.withDayOfMonth(1).atStartOfDay();
        LocalDateTime end = now.plusMonths(1)
                .withDayOfMonth(1)
                .atStartOfDay();

        List<Object[]> ticketCountCurrentMonthList = ticketRepository.countByStatusInMonth(busCompanyId, start, end);
        List<Object[]> ticketCountLastMonthList =
                ticketRepository.countByStatusInMonth(busCompanyId, start.minusMonths(1), end.minusMonths(1));
        long ticketCountCurrentMonth = 0L;
        long ticketCountLastMonth = 0L;

        for(Object[] x : ticketCountLastMonthList){
            String ticketStatus = x[0].toString();
            long value = Long.parseLong(x[1].toString());
            if(ticketStatus.equals(TicketStatusEnum.PAID.name())
                    || ticketStatus.equals(TicketStatusEnum.HOLDING.name())){
                ticketCountLastMonth += value;
            }
        }

        Map<String, Long> ticketCountCurrentMonthMap = new HashMap<>();
        for(Object[] x : ticketCountCurrentMonthList){
            String ticketStatus = x[0].toString();
            long value = Long.parseLong(x[1].toString());
            if(ticketStatus.equals(TicketStatusEnum.PAID.name()) 
                || ticketStatus.equals(TicketStatusEnum.HOLDING.name())){
                ticketCountCurrentMonth += value;
            }
            ticketCountCurrentMonthMap.put(ticketStatus, value);
        }
        Long paidTicketCount = ticketCountCurrentMonthMap.get(TicketStatusEnum.PAID.name());
        Long cancelledTicketCount = ticketCountCurrentMonthMap.get(TicketStatusEnum.CANCELLED.name());
        Long expiredTicketCount = ticketCountCurrentMonthMap.get(TicketStatusEnum.EXPIRED.name());
        Long holdingTicketCount = ticketCountCurrentMonthMap.get(TicketStatusEnum.HOLDING.name());

        List<String> statusList = new ArrayList<>();
        statusList.add(TicketStatusEnum.PAID.name());
        statusList.add(TicketStatusEnum.HOLDING.name());
        // lỗi
        Object[] ticketIssuerCountCurrentMonth = ticketRepository.countByIssuerInMonth(busCompanyId,
                start, end, statusList);
        // lỗi
        Object[] tempObject = (Object[]) ticketIssuerCountCurrentMonth[0];
        Long appBookedTicketCount = tempObject == null ? 0L : Long.parseLong(tempObject[0].toString());
        Long phoneBookedTicketCount = tempObject == null ? 0L : Long.parseLong(tempObject[1].toString());
        
        return TicketReportResp.builder()
            .ticketCountCurrentMonth(ticketCountCurrentMonth)
            .ticketCountLastMonth(ticketCountLastMonth)
            .paidTicketCount(paidTicketCount)
            .holdingTicketCount(holdingTicketCount)
            .cancelledTicketCount(cancelledTicketCount)
            .expiredTicketCount(expiredTicketCount)
            .appBookedTicketCount(appBookedTicketCount)
            .phoneBookedTicketCount(phoneBookedTicketCount)
            .build();
    }
    public TripReportResp getTripReportResp()
    {
        BusCompany busCompany = checkCompany(JwtHelper.getJwt());
        String busCompanyId = busCompany.getId();
        LocalDate now = LocalDate.now();
        LocalDateTime start = now.withDayOfMonth(1).atStartOfDay();
        LocalDateTime end = now.plusMonths(1)
                .withDayOfMonth(1)
                .atStartOfDay();

        Long activeTripCount = tripRepository.countActiveTrip(busCompanyId, start, end);
        List<TripResponse> nextScheduledTripList = tripRepository.getNextScheduledTripList(busCompanyId,
                LocalDateTime.now(), PageRequest.of(0, 4)).stream().map(tripMapper::toTripResponse).toList();
        return TripReportResp.builder()
                .activeTripCount(activeTripCount)
                .nextScheduledTripList(nextScheduledTripList)
            .build();
    }
    public List<RouteReportResp> getRouteReportResp()
    {
        BusCompany busCompany = checkCompany(JwtHelper.getJwt());
        String busCompanyId = busCompany.getId();
        LocalDate now = LocalDate.now();
        LocalDateTime start = now.withDayOfMonth(1).atStartOfDay();
        LocalDateTime end = now.plusMonths(1)
                .withDayOfMonth(1)
                .atStartOfDay();

        List<RouteReportResp> routeReportRespList = new ArrayList<>();
        List<Object[]> countTicketForHotRouteList = routeRepository
                .countTicketForHotRouteList(busCompanyId, start, end);
        for(Object[] x : countTicketForHotRouteList){
            String routeName = x[0].toString();
            long value = Long.parseLong(x[1].toString());
            routeReportRespList.add(RouteReportResp.builder()
                            .routeName(routeName)
                            .ticketCount(value)
                    .build());
        }
        return routeReportRespList;
   }
}
