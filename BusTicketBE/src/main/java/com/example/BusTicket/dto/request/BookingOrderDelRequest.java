package com.example.BusTicket.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.util.List;

@Getter
public class BookingOrderDelRequest {

    @NotNull(message = "BookingOrder Id không được rỗng")
    private String id;
    @NotNull
    List<String> tripSeatIdList;


}
