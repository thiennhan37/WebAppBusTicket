package com.example.BusTicket.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ApiResponseVNPay {
    public String RspCode = "00";
    public String Message = "Confirm Success";
    public static ApiResponseVNPay success(){
        return ApiResponseVNPay.builder()
                .RspCode("00")
                .Message("Confirm Success")
                .build();
    }

    public static ApiResponseVNPay fail(){
        return ApiResponseVNPay.builder()
                .RspCode("99")
                .Message("Confirm Failed")
                .build();
    }
}
