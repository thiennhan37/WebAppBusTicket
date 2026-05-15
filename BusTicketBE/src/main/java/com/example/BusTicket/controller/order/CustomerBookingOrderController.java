package com.example.BusTicket.controller.order;

import com.example.BusTicket.dto.request.BookingOrderCrRequest;
import com.example.BusTicket.dto.request.CompHoldSeatRequest;
import com.example.BusTicket.dto.request.CustomerHoldAndPayRequest;
import com.example.BusTicket.dto.request.CustomerPaymentRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.BookingOrderResponse;
import com.example.BusTicket.dto.response.MomoPaymentResponse;
import com.example.BusTicket.service.CustomerBookingForOrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class CustomerBookingOrderController {
    private final CustomerBookingForOrderService customerBookingForOrderService;

//    @PostMapping("/customer/orders/hold-seats/{id}")
//    ApiResponse<MomoPaymentResponse> holdSeatsAndBookOrderByCustomer(@RequestBody CustomerHoldAndPayRequest request, @PathVariable("id") String tripId) {
//        return ApiResponse.success(customerBookingForOrderService.holdSeatsAndBookOrderByCustomer(request, tripId));
//    }

    @PostMapping("/customer/orders/hold-seats/{id}")
    public ApiResponse<String> holdSeats(@RequestBody CompHoldSeatRequest request, @PathVariable("id") String tripId) {
        // JWT validation tự động qua @PreAuthorize
        String orderId = customerBookingForOrderService.holdSeatsByCustomer(request, tripId);
        return ApiResponse.success(orderId);
    }

    @PostMapping("/customer/orders/payment/{orderId}")
    public ApiResponse<MomoPaymentResponse> createPayment(@PathVariable("orderId") String orderId, @RequestBody CustomerPaymentRequest request) {
        // JWT validation tự động qua @PreAuthorize
        MomoPaymentResponse response = customerBookingForOrderService.createPaymentForOrder(orderId, request);
        return ApiResponse.success(response);
    }

    @GetMapping("/customer/orders/payment-status")
    ApiResponse<Boolean> isOrderPaid(@RequestParam("bookingOrderId") String bookingOrderId) {
        return ApiResponse.success(customerBookingForOrderService.isOrderPaid(bookingOrderId));
    }

}