package com.example.BusTicket.dto.response.report;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class StaffReportResp {
    private Long staffCountCurrentMonth;
    private Long staffCountPreviousMonth;
}
