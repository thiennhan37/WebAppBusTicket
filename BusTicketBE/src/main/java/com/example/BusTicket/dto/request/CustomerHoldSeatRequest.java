package com.example.BusTicket.dto.request;


import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CustomerHoldSeatRequest {
    @NotNull
    private Long arrivalId;
    @NotNull
    private List<String> tripSeatIdList;
    @NotNull
    private Long destinationId;
}
