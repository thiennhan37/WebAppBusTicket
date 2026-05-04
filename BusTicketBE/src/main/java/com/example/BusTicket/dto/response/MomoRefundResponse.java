package com.example.BusTicket.dto.response;

import lombok.Builder;
import lombok.Data;

import java.util.Map;

@Data
@Builder
public class MomoRefundResponse {
    private String momoOrderId;
    private Long transId;
    private Long resultCode;

}
