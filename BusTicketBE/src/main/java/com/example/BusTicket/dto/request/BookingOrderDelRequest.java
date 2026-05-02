package com.example.BusTicket.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.util.List;

@Getter
public class BookingOrderDelRequest {

    @NotNull(message = "BookingOrderId không được rỗng")
    private String bookingOrderId;
    @NotNull
    private List<String> tripSeatIdList;


}
