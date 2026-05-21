package com.example.BusTicket.dto.response.companyReport;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class RevenueReportResp {
    private Long revenueCurrentMonth;
    private Long revenueLastMonth;
    // list danh sách tổng doanh thu theo tuần của tháng hiện tại
    private List<Long> revenueWeekList;
}

