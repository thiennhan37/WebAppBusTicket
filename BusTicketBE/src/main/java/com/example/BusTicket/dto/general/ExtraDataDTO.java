package com.example.BusTicket.dto.general;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder @NoArgsConstructor @AllArgsConstructor
public class ExtraDataDTO {
    private String type;
//    private String bookingId;
//    private String userId;
//    private String plan;
}
