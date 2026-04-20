package com.example.BusTicket.dto.general;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;


@Builder
@AllArgsConstructor @NoArgsConstructor
@Data
public class BusDiagram {
    private int floor, row, column;
    private List<List<List<String>>> seatList;
}
