package com.example.BusTicket.controller.order;

import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.entity.TripSeat;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/tickets")
@RequiredArgsConstructor
public class TicketController {
    @PostMapping("/hold-seat/{id}")
    ApiResponse<BookingOrder> holdTripSeat(@RequestBody List<String> tripSeatIdList, @PathVariable("id") String tripId) {
        return
    }
}
