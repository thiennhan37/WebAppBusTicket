package com.example.BusTicket.controller.customer;


import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.CustomerDetailOrderRespone;
import com.example.BusTicket.dto.response.CustomerOrderHistoryResponse;
import com.example.BusTicket.service.CustomerManagerBookingOrderService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
public class CustomerManagerBookingOrderController {
    private final CustomerManagerBookingOrderService customerManagerBookingOrderService;

    @GetMapping("/customer/orders/recent")
    ApiResponse<List<CustomerOrderHistoryResponse>> getRecentOrders() {
        return ApiResponse.success(customerManagerBookingOrderService.getRecentOrdersForCustomer());
    }

    @PostMapping("/customer/orders/unhold-seats/{orderId}")
    public ApiResponse<Boolean> unHoldSeats(@PathVariable("orderId") String orderId) {
        return ApiResponse.success(customerManagerBookingOrderService.unHoldSeatsByCustomer(orderId));
    }

    @GetMapping("customer/order/detail/{orderId}")
    public ApiResponse<CustomerDetailOrderRespone> detailOrder(@PathVariable("orderId") String orderId) {
        return ApiResponse.success(customerManagerBookingOrderService.getOrderDetail(orderId));
    }
}
