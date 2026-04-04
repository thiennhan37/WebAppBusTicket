package com.example.BusTicket.dto.response;

import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.Province;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RouteResponse {
    @Id
    private Long id;
    private String name;

    private Province arrivalProvince;
    private Province destinationProvince;
}
