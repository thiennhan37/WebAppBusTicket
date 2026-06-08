package com.example.BusTicket.controller.order;

import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.ApiResponseVNPay;
import com.example.BusTicket.dto.response.VNPayPaymentResponse;
import com.example.BusTicket.service.PaymentService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/vnpay")
@RequiredArgsConstructor
@Slf4j
public class VNPayController {

    private final PaymentService paymentService;
    

    @PostMapping("/payment-url/{order-id}")
    ApiResponse<VNPayPaymentResponse> getVNPayUrlForCustomer(
            @PathVariable("order-id") String orderId,
            HttpServletRequest httpRequest) {
        String ipAddress = getClientIpAddress(httpRequest);
        var payment = paymentService.createPaymentForBooking(orderId);
        return ApiResponse.success(paymentService.getVNPayUrlForCustomer(payment.getId(), ipAddress));
    }

    /**
     * VNPay gọi IPN về đây (GET với query params).
     * Trả về ApiResponseVNPay với RspCode=00 & Message=Confirm Success theo yêu cầu VNPay.
     */
    @GetMapping("/ipn")
    ApiResponseVNPay handleVNPayIPN(@RequestParam Map<String, String> params) {
        log.info("VNPay IPN received: {}", params);
        try {
            paymentService.handleVNPayIpn(params);
            return ApiResponseVNPay.success();
        } catch (Exception e) {
            log.error("VNPay IPN error: {}", e.getMessage(), e);
            return ApiResponseVNPay.fail();
        }
    }

    /**
     * VNPay redirect user về đây sau khi thanh toán xong (GET).
     * Chỉ dùng để frontend redirect, không xử lý logic – IPN mới là luồng chính.
     */
    @GetMapping("/return")
    ApiResponse<Map<String, String>> handleVNPayReturn(@RequestParam Map<String, String> params) {
        log.info("VNPay return params: {}", params);
        String responseCode = params.get("vnp_ResponseCode");
        Map<String, String> result = new HashMap<>();
        result.put("responseCode", responseCode);
        result.put("txnRef", params.getOrDefault("vnp_TxnRef", ""));
        result.put("transactionNo", params.getOrDefault("vnp_TransactionNo", ""));
        return ApiResponse.success(result);
    }

    // -------------------------------------------------------
    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp;
        }
        return request.getRemoteAddr();
    }
}
