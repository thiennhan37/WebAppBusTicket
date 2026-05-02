package com.example.BusTicket.dto.request;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MomoPaymentRequest {

    private String bookingOrderId;
    private String amount;
    private String orderInfo;
    private String transId;
    private String type;
}
