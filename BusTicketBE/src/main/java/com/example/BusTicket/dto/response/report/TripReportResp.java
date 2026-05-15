package com.example.BusTicket.dto.response.report;

import lombok.Builder;
import lombok.Data;
import com.example.BusTicket.dto.response.TripResponse;

import java.util.List;

@Data
@Builder
public class TripReportResp {
    // tổng số chuyến chạy hôm nay
    private Long activeTripCount;
    //danh sách chuyến sắp chạy
    List<TripResponse> nextScheduledTripList;
}

