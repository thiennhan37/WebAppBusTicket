package com.example.BusTicket.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentRequest {

    private String requestId;
    private String bookingOrderId;
    private String type;
    private Long transId;
    private Long parentTransId;
}
