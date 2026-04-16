package com.example.BusTicket.service;

import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.repository.jpa.BookingOrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BookingOrderService {
    private final BookingOrderRepository bookingOrderRepository;

    public BookingOrder holdTripSeat(List<String> tripSeatIdList, String tripId){

    }

}
