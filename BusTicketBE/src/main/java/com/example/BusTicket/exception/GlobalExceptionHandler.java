package com.example.BusTicket.exception;

import com.example.BusTicket.dto.response.ApiResponse;
import com.nimbusds.jose.JOSEException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(value = Exception.class)
    ResponseEntity<ApiResponse> handleException(Exception exception){
        System.out.println("có lỗi " + exception.toString());
        return ResponseEntity.status(ErrorCode.UNCATEGORIZED_EXCEPTION.getStatusCode())
                .body(ApiResponse.error(ErrorCode.UNCATEGORIZED_EXCEPTION));
    }
    @ExceptionHandler(value = MethodArgumentNotValidException.class)
    ResponseEntity<ApiResponse> handleException(MethodArgumentNotValidException exception){

//        System.out.println(exception.getMessage());
        return ResponseEntity.status(ErrorCode.VALIDATION_FAILED.getStatusCode())
                .body(ApiResponse.error(ErrorCode.VALIDATION_FAILED));
    }
    @ExceptionHandler(value = MyAppException.class)
    public ResponseEntity<ApiResponse> handleMyAppException(MyAppException exception){
        ErrorCode errorCode = exception.getErrorCode();
        System.out.println("xử lí MyAppException\n" + exception.getMessage());
        return ResponseEntity.status(errorCode.getStatusCode())
                .body(ApiResponse.error(errorCode));
    }

}
