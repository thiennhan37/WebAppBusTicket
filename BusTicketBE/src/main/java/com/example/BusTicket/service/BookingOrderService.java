package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.BookingOrderCrRequest;
import com.example.BusTicket.dto.request.BookingOrderDelRequest;
import com.example.BusTicket.dto.request.CompHoldSeatRequest;
import com.example.BusTicket.dto.response.BookingOrderResponse;
import com.example.BusTicket.entity.*;
import com.example.BusTicket.enums.HistoryStatusEnum;
import com.example.BusTicket.enums.TicketStatusEnum;
import com.example.BusTicket.enums.TripSeatEnum;
import com.example.BusTicket.enums.TripStatusEnum;
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
public class BookingOrderService {
    private final BookingOrderRepository bookingOrderRepository;
    private final BookingOrderMapper bookingOrderMapper;
    private final TicketRepository ticketRepository;
    private final TripSeatRepository tripSeatRepository;


    public BookingOrderResponse getBookingOrder(String bookingOrderId){
        BookingOrder bookingOrder = bookingOrderRepository.findById(bookingOrderId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        return bookingOrderMapper.toBookingOrderResponse(bookingOrder);
    }

    public void paymentSuccessfully(String bookingOrderId){
        List<Ticket> ticketList = ticketRepository.getTicketsBecomeSuccessfulPayment(bookingOrderId);
        List<TripSeat> tripSeatList = ticketList.stream().map(Ticket::getTripSeat).toList();

        for(TripSeat ts : tripSeatList) ts.setStatus(TripSeatEnum.BOOKED.name());
        for(Ticket t : ticketList) t.setStatus(TicketStatusEnum.PAID.name());

        tripSeatRepository.saveAll(tripSeatList);
        ticketRepository.saveAll(ticketList);
    }
}
