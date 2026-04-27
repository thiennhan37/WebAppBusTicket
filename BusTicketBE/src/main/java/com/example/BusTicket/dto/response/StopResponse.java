package com.example.BusTicket.dto.response;

import com.example.BusTicket.entity.Customer;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor @AllArgsConstructor @Builder
public class StopResponse {

    private Long id;
    private String name, address;
}
