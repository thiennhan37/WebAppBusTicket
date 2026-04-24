package com.example.BusTicket.controller.order;

import com.example.BusTicket.dto.request.BookingOrderCrRequest;
import com.example.BusTicket.dto.request.BookingOrderDelRequest;
import com.example.BusTicket.dto.request.CompHoldSeatRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.BookingOrderResponse;
import com.example.BusTicket.service.BookingForOrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
//@RequestMapping("/orders")
@RequiredArgsConstructor
public class BookingOrderController {
    private final BookingForOrderService bookingForOrderService;

    @PostMapping("/nhaxe/orders/hold-seats/{id}")
    ApiResponse<String> companyHoldTripSeats(@RequestBody CompHoldSeatRequest request, @PathVariable("id") String tripId) {
        return ApiResponse.success(bookingForOrderService.holdSeatsByCompany(request, tripId));
    }
    @PostMapping("/nhaxe/orders/book-order/{id}")
    ApiResponse<BookingOrderResponse> companyBookOrder(@RequestBody BookingOrderCrRequest request, @PathVariable("id") String tripId) {
        return ApiResponse.success(bookingForOrderService.bookOrderByCompany(request, tripId));
    }
    @DeleteMapping("/nhaxe/orders/delete-order/{id}")
    ApiResponse<Boolean> companyDeleteOrder(@RequestBody BookingOrderDelRequest request, @PathVariable("id") String tripId) {
        return ApiResponse.success(bookingForOrderService.deleteInvalidOrder(request, tripId));
    }
//    @PutMapping("/nhaxe/orders/cancel-order/{id}")
//    ApiResponse<Boolean> cancelTicket(@RequestBody BookingOrderCrRequest request, @PathVariable("id") String tripId) {
//        return ApiResponse.success(bookingOrderService.bookOrderByCompany(request, tripId));
//    }
}
