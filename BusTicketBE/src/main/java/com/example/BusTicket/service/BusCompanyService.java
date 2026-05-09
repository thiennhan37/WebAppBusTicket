package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.UpdateTicketRequest;
import com.example.BusTicket.dto.response.BookingOrderResponse;
import com.example.BusTicket.dto.response.TicketResponse;
import com.example.BusTicket.entity.*;
import com.example.BusTicket.enums.TicketStatusEnum;
import com.example.BusTicket.enums.TripSeatEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.BookingOrderMapper;
import com.example.BusTicket.mapper.TicketMapper;
import com.example.BusTicket.repository.jpa.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BusCompanyService {
    private final BookingOrderRepository bookingOrderRepository;
    private final BookingOrderMapper bookingOrderMapper;
    private final TicketRepository ticketRepository;
    private final TripSeatRepository tripSeatRepository;
    private final CompanyUserRepository companyUserRepository;
    private final TripRepository tripRepository;
    private final RouteStopRepository routeStopRepository;
    private final TicketMapper ticketMapper;
    private final BusCompanyRepository busCompanyRepository;


    public BusCompany getBusCompany(String busCompanyId) {
        Jwt jwt = JwtHelper.getJwt();
        CompanyUser companyUser = checkPermission(jwt.getSubject(), busCompanyId);
        return companyUser.getBusCompany();
    }

    public BusCompany updateBusCompany(String busCompanyId, ) {
        Jwt jwt = JwtHelper.getJwt();
        CompanyUser companyUser = checkPermission(jwt.getSubject(), busCompanyId);
        BusCompany busCompany = companyUser.getBusCompany();

        return busCompany;
    }
    private CompanyUser checkPermission(String companyUserId, String busCompanyId){
        CompanyUser companyUser = companyUserRepository.findById(companyUserId)
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = busCompanyRepository.findById(busCompanyId)
                .orElseThrow(() -> new MyAppException(ErrorCode.COMPANY_NOT_EXISTED));
        if( !companyUser.getBusCompany().getId().equals(busCompanyId))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);
        return companyUser;
    }

}
