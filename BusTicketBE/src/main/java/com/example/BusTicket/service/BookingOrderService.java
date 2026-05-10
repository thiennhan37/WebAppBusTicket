package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.BookingOrderCrRequest;
import com.example.BusTicket.dto.request.BookingOrderDelRequest;
import com.example.BusTicket.dto.request.CompHoldSeatRequest;
import com.example.BusTicket.dto.request.UpdateTicketRequest;
import com.example.BusTicket.dto.response.BookingOrderResponse;
import com.example.BusTicket.dto.response.TicketResponse;
import com.example.BusTicket.entity.*;
import com.example.BusTicket.enums.HistoryStatusEnum;
import com.example.BusTicket.enums.TicketStatusEnum;
import com.example.BusTicket.enums.TripSeatEnum;
import com.example.BusTicket.enums.TripStatusEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.BookingOrderMapper;
import com.example.BusTicket.mapper.TicketMapper;
import com.example.BusTicket.repository.jpa.*;
import com.example.BusTicket.util.IdUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class BookingOrderService {
    private final BookingOrderRepository bookingOrderRepository;
    private final BookingOrderMapper bookingOrderMapper;
    private final TicketRepository ticketRepository;
    private final TripSeatRepository tripSeatRepository;
    private final CompanyUserRepository companyUserRepository;
    private final TripRepository tripRepository;
    private final RouteStopRepository routeStopRepository;
    private final TicketMapper ticketMapper;
    private final RedisTemplate<String, String> redisTemplate;

    @Value("${booking.customerHoldingSeatPrefixKey}")
    private String CUSTOMER_HOLD_INFO_PREFIX;


    public BookingOrderResponse getBookingOrder(String bookingOrderId) {
        BookingOrder bookingOrder = bookingOrderRepository.findById(bookingOrderId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        return bookingOrderMapper.toBookingOrderResponse(bookingOrder);
    }

    public void paymentSuccessfully(String bookingOrderId){
        List<Ticket> ticketList = ticketRepository.getTicketsBecomeSuccessfulPayment(bookingOrderId);
        List<TripSeat> tripSeatList = ticketList.stream().map(Ticket::getTripSeat).toList();

        for(TripSeat ts : tripSeatList) ts.setStatus(TripSeatEnum.BOOKED.name());
        for(Ticket t : ticketList) t.setStatus(TicketStatusEnum.PAID.name());
        BookingOrder bookingOrder = ticketList.isEmpty() ? bookingOrderRepository.findById(bookingOrderId).orElse(null) : ticketList.get(0).getBookingOrder();
        if(bookingOrder != null && bookingOrder.getBookingUser() != null){
            redisTemplate.delete(CUSTOMER_HOLD_INFO_PREFIX + bookingOrder.getBookingUser().getId());
        }

        tripSeatRepository.saveAll(tripSeatList);
        ticketRepository.saveAll(ticketList);
    }
    @Transactional
    public TicketResponse updateTicketByCompany(UpdateTicketRequest request, String tripId){
        Jwt jwt = JwtHelper.getJwt();
        CompanyUser companyUser = companyUserRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        if( !companyUser.getBusCompany().getId().equals(trip.getBusCompany().getId()))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);
        Ticket ticket = ticketRepository.findById(request.getTicketId())
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        if(!ticket.getTripSeat().getTrip().getId().equals(tripId)) throw new MyAppException(ErrorCode.TICKET_INVALID);

        if(request.getArrivalId() != null){
            RouteStop arrival = routeStopRepository.findById(request.getArrivalId())
                    .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
            ticket.setArrival(arrival);
        }
        if(request.getDestinationId() != null){
            RouteStop destination = routeStopRepository.findById(request.getDestinationId())
                    .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
            ticket.setDestination(destination);
        }
        BookingOrder bookingOrder = ticket.getBookingOrder();
        if(request.getCustomerName() != null && !request.getCustomerName().isBlank())
            bookingOrder.setCustomerName(request.getCustomerName());
        if(request.getCustomerPhone() != null && !request.getCustomerPhone().isBlank())
            bookingOrder.setCustomerPhone(request.getCustomerPhone());
        ticketRepository.save(ticket);
        bookingOrderRepository.save(bookingOrder);
        return ticketMapper.toTicketResponse(ticket);
    }
}
