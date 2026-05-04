package com.example.BusTicket.controller.order;

import com.example.BusTicket.dto.request.*;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.BookingOrderResponse;
import com.example.BusTicket.dto.response.TicketResponse;
import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.service.BookingForOrderService;
import com.example.BusTicket.service.BookingOrderService;
import com.example.BusTicket.service.CancelForOrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
//@RequestMapping("/orders")
@RequiredArgsConstructor
public class BookingOrderController {
    private final BookingForOrderService bookingForOrderService;
    private final CancelForOrderService cancelForOrderService;
    private final BookingOrderService bookingOrderService;

    @PostMapping("/nhaxe/orders/hold-seats/{id}")
    ApiResponse<String> companyHoldTripSeats(@RequestBody CompHoldSeatRequest request, @PathVariable("id") String tripId) {
        return ApiResponse.success(bookingForOrderService.holdSeatsByCompany(request, tripId));
    }
    @PostMapping("/nhaxe/orders/unhold-seats/{id}")
    ApiResponse<Boolean> companyUnHoldSeats(@RequestBody BookingOrderDelRequest request, @PathVariable("id") String tripId) {
        return ApiResponse.success(bookingForOrderService.unHoldSeats(request, tripId));
    }
    @PostMapping("/nhaxe/orders/book-order/{id}")
    ApiResponse<BookingOrderResponse> bookOrderByCompany(@RequestBody BookingOrderCrRequest request, @PathVariable("id") String tripId) {
        return ApiResponse.success(bookingForOrderService.bookOrderByCompany(request, tripId));
    }
    @PostMapping("/nhaxe/orders/cancel-tickets/{id}")
    ApiResponse<Boolean> cancelTicketByCompany(@RequestBody CancelTicketRequest request, @PathVariable("id") String tripId) {
        return ApiResponse.success(cancelForOrderService.cancelTicketByCompany(request, tripId));
    }
    @PutMapping("/nhaxe/orders/update-ticket/{id}")
    ApiResponse<TicketResponse> updateTicketByCompany(@RequestBody UpdateTicketRequest request, @PathVariable("id") String tripId) {
        return ApiResponse.success(bookingOrderService.updateTicketByCompany(request, tripId));
    }

//    @PutMapping("/nhaxe/orders/cancel-order/{id}")
//    ApiResponse<Boolean> cancelTicket(@RequestBody BookingOrderCrRequest request, @PathVariable("id") String tripId) {
//        return ApiResponse.success(bookingOrderService.bookOrderByCompany(request, tripId));
//    }
}
