package com.example.BusTicket.dto.response;

import com.example.BusTicket.exception.ErrorCode;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ApiResponse<T> {
    public int code = 1000;
    public String message = "Successful";
    public T result;

    public static <T> ApiResponse<T> success(T t){
        return ApiResponse.<T>builder()
                .result(t)
                .build();
    }
    public static ApiResponse<?> error(ErrorCode errorCode){
        return ApiResponse.builder()
                .code(errorCode.getCode())
                .message(errorCode.getMessage())
                .build();
    }
}
