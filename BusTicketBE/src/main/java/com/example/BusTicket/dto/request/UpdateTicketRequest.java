package com.example.BusTicket.dto.request;

import lombok.Getter;

@Getter
public class UpdateTicketRequest {
    private String ticketId;
    private String customerName;
    private String customerPhone;
    private Long arrivalId;
    private Long destinationId;
}
