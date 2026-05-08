package com.example.BusTicket.dto.response;

import com.example.BusTicket.entity.Province;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RouteResponse {
    private Long id;
    private String name;
    private Integer durationMinutes;
    private Province arrivalProvince;
    private Province destinationProvince;
    private List<StopResponse> upStopList;
    private List<StopResponse> downStopList;
}
