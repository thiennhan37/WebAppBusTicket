package com.example.BusTicket.dto.response;

import com.example.BusTicket.dto.general.BusDiagram;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class CustomerSearchBusDiagramRespone {
    private String busTypeName;
    private BusDiagram diagram;
    private List<SeatInfo> seats;

    @Data
    @Builder
    @AllArgsConstructor
    @NoArgsConstructor
    public static class SeatInfo {
        private String seatId;
        private String seatCode;
        private String status; // AVAILABLE, HELD, BOOKED
        private Long price;
    }
}
