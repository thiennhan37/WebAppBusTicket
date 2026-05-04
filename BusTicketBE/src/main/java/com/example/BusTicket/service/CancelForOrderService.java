package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.BookingOrderCrRequest;
import com.example.BusTicket.dto.request.BookingOrderDelRequest;
import com.example.BusTicket.dto.request.CancelTicketRequest;
import com.example.BusTicket.dto.request.CompHoldSeatRequest;
import com.example.BusTicket.dto.response.BookingOrderResponse;
import com.example.BusTicket.entity.*;
import com.example.BusTicket.enums.HistoryStatusEnum;
import com.example.BusTicket.enums.TicketStatusEnum;
import com.example.BusTicket.enums.TripSeatEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.BookingOrderMapper;
import com.example.BusTicket.repository.jpa.*;
import com.example.BusTicket.util.IdUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class CancelForOrderService {
    private final BookingOrderRepository bookingOrderRepository;
    private final SeatReservationService seatReservationService;
    private final CustomerRepository customerRepository;
    private final TripSeatRepository tripSeatRepository;
    private final TripRepository tripRepository;
    private final CompanyUserRepository companyUserRepository;
    private final RouteStopRepository routeStopRepository;
    private final TicketRepository ticketRepository;
    private final BookingOrderMapper orderMapper;
    private final HistoryBookingRepository historyBookingRepository;
    private final HistoryDetailRepository historyDetailRepository;


    @Value("${booking.holdingSeatTime}")
    private int holdingSeatTime;


    @Transactional
    public boolean cancelTicketByCompany(CancelTicketRequest request){
        Jwt jwt = JwtHelper.getJwt();
        List<String> ticketIdList = request.getTicketIdList();
        List<TripSeat> tripSeatList = tripSeatRepository.getTripSeatsForCancel(ticketIdList);
        if(tripSeatList.size() != ticketIdList.size())
            throw new MyAppException(ErrorCode.TICKET_INVALID);
        List<String> tripSeatIdList = tripSeatList.stream().map(TripSeat::getId).toList();
        List<Trip> tripList = tripRepository.getTripForCancelTicket(tripSeatIdList);
        if(tripList.size() != 1) throw new MyAppException(ErrorCode.TRIP_SEAT_INVALID);
        Trip trip = tripList.getFirst();
        CompanyUser companyUser = checkCompanyPermission(jwt.getSubject(), trip);
        // update status ticket to  cancelled
        int rowUpdTicket =  ticketRepository.updateStatusByIds(ticketIdList, TicketStatusEnum.CANCELLED.name(), TicketStatusEnum.PAID.name());
        if(rowUpdTicket != ticketIdList.size()) throw new MyAppException(ErrorCode.ERROR_SAVED);

        int rowUpdTripSeat = tripSeatRepository.updateStatusByIds(tripSeatIdList, TripSeatEnum.AVAILABLE.name(), TripSeatEnum.BOOKED.name());
        if(rowUpdTripSeat != tripSeatIdList.size()) throw new MyAppException(ErrorCode.ERROR_SAVED);

        return true;
    }

    private CompanyUser checkCompanyPermission(String companyUserId, Trip trip){
        CompanyUser companyUser = companyUserRepository.findById(companyUserId)
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        if( !companyUser.getBusCompany().getId().equals(trip.getBusCompany().getId()))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);
        return companyUser;
    }

}
