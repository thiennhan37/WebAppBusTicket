package com.example.BusTicket.dto.request;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MomoPaymentRequest {

    private String paymentId;
    private String bookingOrderId;
    private String orderInfo;
    private Long transId;
    private String type;
}
