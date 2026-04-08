package com.example.BusTicket.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;

@Getter
public enum ErrorCode {
    UNCATEGORIZED_EXCEPTION(9999, "Uncategorized exception", HttpStatus.INTERNAL_SERVER_ERROR),
    UNAUTHENTICATED(1001, "Unauthenticated exception", HttpStatus.UNAUTHORIZED),
    INVALID_TOKEN(1002, "Invalid token exception", HttpStatus.UNAUTHORIZED),
    VALIDATION_FAILED(1003, "Invalid condition", HttpStatus.BAD_REQUEST),
    ACCESS_DENIED(1004, "You do not have permission", HttpStatus.FORBIDDEN),
    INVALID_PARAMETER(1005, "Invalid request parameters", HttpStatus.BAD_REQUEST),
    MISSING_REQUIRED_FIELD(1006, "Required field is missing", HttpStatus.BAD_REQUEST),




    COMPANY_NOT_EXISTED(4001, "Company not existed", HttpStatus.BAD_REQUEST),
    EMAIL_EXISTED(4002, "Email existed", HttpStatus.BAD_REQUEST),
    ACCOUNT_NOT_EXISTED(4003, "Account not existed", HttpStatus.BAD_REQUEST),
    ACCOUNT_BLOCKED(4004, "Account has been existed", HttpStatus.FORBIDDEN),
    HOTLINE_EXISTED(4004, "Hotline has been existed", HttpStatus.BAD_REQUEST),
    INFO_EXISTED(4005, "Information has been existed", HttpStatus.BAD_REQUEST),
    ;
    private int code;
    private String message;
    private HttpStatusCode statusCode;

    ErrorCode(int code, String message, HttpStatusCode statusCode) {
        this.code = code;
        this.message = message;
        this.statusCode = statusCode;
    }



//    DATA_TYPE_MISMATCH(1003, "Data type mismatch (e.g. expected number, got string)", HttpStatus.BAD_REQUEST),
//    VALUE_OUT_OF_RANGE(1004, "Value is out of allowed range", HttpStatus.BAD_REQUEST),
//    STRING_TOO_LONG(1005, "Input string exceeds maximum length", HttpStatus.BAD_REQUEST),
//    INVALID_FORMAT(1006, "Data format is invalid (e.g. invalid email or regex)", HttpStatus.BAD_REQUEST),
//    MALFORMED_JSON(1007, "JSON body is malformed or unreadable", HttpStatus.BAD_REQUEST);
}
