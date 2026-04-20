package com.example.BusTicket.dto.request;

import com.example.BusTicket.entity.Stop;
import com.example.BusTicket.validatior.BirthConstraint;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.time.LocalDate;
import java.util.List;

@Getter
public class RouteCrRequest {
    @NotNull
    private String name;
    @NotNull
    private String busCompanyId;
    @NotNull
    private String arrivalId;
    @NotNull
    private String destinationId;
    @NotNull
    private List<Long> upStopIdList;
    @NotNull
    private List<Long> downStopIdList;
}
