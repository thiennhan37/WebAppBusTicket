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

//    private String bookingOrderId;
    private Long transId;
    private Long amount;
    private String description;
}
