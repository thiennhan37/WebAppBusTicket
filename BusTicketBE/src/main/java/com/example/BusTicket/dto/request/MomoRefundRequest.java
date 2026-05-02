package com.example.BusTicket.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MomoRefundRequest {

    private String bookingOrderId;
    private String transId;
    private String amount;
    private String description;
}
