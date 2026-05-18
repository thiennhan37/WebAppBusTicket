package com.example.BusTicket.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;

import java.util.List;

@Data
@Builder
public class CancelTicketRequest {

    @NotNull
    List<String> ticketIdList;


}
