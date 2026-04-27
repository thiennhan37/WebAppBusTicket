package com.example.BusTicket.dto.request;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MomoCreateRequest {

    private String orderId;
    private String amount;
    private String orderInfo;
    private String type;
}
