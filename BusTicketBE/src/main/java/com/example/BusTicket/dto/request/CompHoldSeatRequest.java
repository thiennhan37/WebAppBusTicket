package com.example.BusTicket.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.util.List;

@Getter
public class CompHoldSeatRequest {
    @NotNull
    private List<String> tripSeatIdList;
}
