package com.example.BusTicket.controller.order;

import com.example.BusTicket.dto.request.BookingOrderCrRequest;
import com.example.BusTicket.dto.request.CompHoldSeatRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.BookingOrderResponse;
import com.example.BusTicket.service.CustomerBookingForOrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class CustomerBookingOrderController {
    private final CustomerBookingForOrderService customerBookingForOrderService;

    @PostMapping("/customer/orders/hold-seats/{id}")
    ApiResponse<String> customerHoldTripSeats(@RequestBody CompHoldSeatRequest request, @PathVariable("id") String tripId) {
        return ApiResponse.success(customerBookingForOrderService.holdSeatsByCustomer(request, tripId));
    }

    @PostMapping("/customer/orders/book-order/{id}")
    ApiResponse<BookingOrderResponse> bookOrderByCustomer(@RequestBody BookingOrderCrRequest request, @PathVariable("id") String tripId) {
        return ApiResponse.success(customerBookingForOrderService.bookOrderByCustomer(request, tripId));
    }
}