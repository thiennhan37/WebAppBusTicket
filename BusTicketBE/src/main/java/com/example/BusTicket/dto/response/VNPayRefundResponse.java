package com.example.BusTicket.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VNPayRefundResponse {
    private String vnpTxnRef;    // Mã giao dịch của merchant (= paymentId)
    private String responseCode; // "00" = thành công
    private String transactionNo; // Mã giao dịch của VNPay
    private String message;
}
