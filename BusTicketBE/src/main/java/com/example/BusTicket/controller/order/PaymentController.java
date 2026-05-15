package com.example.BusTicket.controller.order;

import com.example.BusTicket.configuration.MomoConfiguration;
import com.example.BusTicket.dto.request.MomoPaymentRequest;
import com.example.BusTicket.dto.request.MomoRefundRequest;
import com.example.BusTicket.dto.request.PaymentRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.MomoPaymentResponse;
import com.example.BusTicket.dto.response.MomoRefundResponse;
import com.example.BusTicket.dto.response.PaymentUrlResponse;
import com.example.BusTicket.enums.AccountType;
import com.example.BusTicket.enums.MomoEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.service.MomoService;
import com.example.BusTicket.service.PaymentService;
import com.example.BusTicket.util.MomoUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/momo")
@RequiredArgsConstructor
public class PaymentController {
    private final MomoService momoService;
    private final MomoUtil momoUtil;
    private final MomoConfiguration momoConfiguration;
    private final PaymentService paymentService;


    @PostMapping("/payment-url")
    ApiResponse<PaymentUrlResponse> getPayUrlForCustomer(@RequestBody Map<String, String> request) {
        return ApiResponse.success(paymentService.getPayUrlForCustomer(request.get("paymentId")));
    }

    @PostMapping("/payment")
    ApiResponse<MomoPaymentResponse> createPayment(@RequestBody MomoPaymentRequest request) {
        return ApiResponse.success(momoService.createMomoPayment(request, AccountType.COMPANY));
    }
    @PostMapping("/refund")
    ApiResponse<MomoRefundResponse> createRefund(@RequestBody MomoRefundRequest request) {
        return ApiResponse.success(momoService.createMomoRefund(request));
    }
    @PostMapping("/ipn")
    public ApiResponse<Boolean> handleMomoIPN(@RequestBody Map<String, Object> payload) {
        return ApiResponse.success(paymentService.handleMomoIpn(payload));
    }

}



