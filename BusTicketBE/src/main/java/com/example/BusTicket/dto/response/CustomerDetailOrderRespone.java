package com.example.BusTicket.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerDetailOrderRespone {
    private String bookingOrderId;
    private String pickupProvinceId;
    private String pickupProvince;
    private String dropoffProvinceId;
    private String dropoffProvince;
    private Long pickupStopId;
    private Long dropoffStopId;
    private String pickupStop;
    private String dropoffStop;
    private String busCompanyId;
    private String busCompanyName;
    private LocalDateTime departureTime;
    private String busType;
    private Integer seatCount;
    private List<String> seatCodes;
    private Long totalAmount;
    private String contactName;
    private String contactPhone;
    private String contactEmail;

}
