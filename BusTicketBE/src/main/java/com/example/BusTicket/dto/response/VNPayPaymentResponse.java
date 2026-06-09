package com.example.BusTicket.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VNPayPaymentResponse {
    private String payUrl;
    /** vnp_CreateDate gửi khi tạo URL thanh toán – dùng cho refund (vnp_TransactionDate) */
    private String vnpCreateDate;
}


