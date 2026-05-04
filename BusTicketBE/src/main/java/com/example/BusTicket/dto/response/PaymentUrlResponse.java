package com.example.BusTicket.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class PaymentUrlResponse {
    private String payUrl;
}
