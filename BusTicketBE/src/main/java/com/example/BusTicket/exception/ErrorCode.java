package com.example.BusTicket.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;

@Getter
public enum ErrorCode {
    UNCATEGORIZED_EXCEPTION(9999, "Uncategorized exception", HttpStatus.INTERNAL_SERVER_ERROR),
    UNAUTHENTICATED(1001, "Unauthenticated exception", HttpStatus.UNAUTHORIZED),
    INVALID_TOKEN(1002, "Invalid token exception", HttpStatus.UNAUTHORIZED),
    COMPANY_NOT_EXISTED(4001, "Company not existed", HttpStatus.BAD_REQUEST),
    EMAIL_EXISTED(4002, "Email existed", HttpStatus.BAD_REQUEST),
    ACCOUNT_NOT_EXISTED(4003, "Account not existed", HttpStatus.BAD_REQUEST),
    ;
    private int code;
    private String message;
    private HttpStatusCode statusCode;

    ErrorCode(int code, String message, HttpStatusCode statusCode) {
        this.code = code;
        this.message = message;
        this.statusCode = statusCode;
    }
}
