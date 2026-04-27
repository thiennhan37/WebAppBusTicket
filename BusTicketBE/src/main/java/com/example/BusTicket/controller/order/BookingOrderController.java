package com.example.BusTicket.controller.order;

import com.example.BusTicket.dto.request.BookingOrderCrRequest;
import com.example.BusTicket.dto.request.BookingOrderDelRequest;
import com.example.BusTicket.dto.request.CompHoldSeatRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.BookingOrderResponse;
import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.service.BookingOrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
//@RequestMapping("/orders")
@RequiredArgsConstructor
public class BookingOrderController {
    private final BookingOrderService bookingOrderService;

    @PostMapping("/nhaxe/orders/hold-seats/{id}")
    ApiResponse<String> companyHoldTripSeats(@RequestBody CompHoldSeatRequest request, @PathVariable("id") String tripId) {
        return ApiResponse.success(bookingOrderService.holdSeatsByCompany(request, tripId));
    }
    @PostMapping("/nhaxe/orders/book-order/{id}")
    ApiResponse<BookingOrderResponse> companyBookOrder(@RequestBody BookingOrderCrRequest request, @PathVariable("id") String tripId) {
        return ApiResponse.success(bookingOrderService.bookOrderByCompany(request, tripId));
    }
    @DeleteMapping("/nhaxe/orders/delete-order/{id}")
    ApiResponse<Boolean> companyDeleteOrder(@RequestBody BookingOrderDelRequest request, @PathVariable("id") String tripId) {
        return ApiResponse.success(bookingOrderService.deleteInvalidOrder(request, tripId));
    }
}
