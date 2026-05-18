package com.example.BusTicket.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerOrderHistoryResponse {
    private String orderId;
    private String departureProvince;
    private String destinationProvince;
    private LocalDateTime departureTime;
    private String busCompanyName;
    private String orderStatus;
    private Long totalCost;
}