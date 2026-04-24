package com.example.BusTicket.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.util.List;

@Getter
public class CancelTicketRequest {

    @NotNull
    List<String> ticketIdList;


}
