package com.example.BusTicket.dto.request;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class MomoCreateRequest {

    private String bookingOrderId;
    private String amount;
    private String orderInfo;

}
