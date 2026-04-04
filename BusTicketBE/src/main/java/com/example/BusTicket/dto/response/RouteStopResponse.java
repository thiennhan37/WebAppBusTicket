package com.example.BusTicket.dto.response;

import com.example.BusTicket.entity.Province;
import com.example.BusTicket.entity.Route;
import com.example.BusTicket.entity.Stop;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RouteStopResponse {
    @Id
    private Long id;
    private String type;
    private Stop stop;
}
