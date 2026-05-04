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
    INVALID_STATE(1007, "Invalid state", HttpStatus.BAD_REQUEST),
    ERROR_REDIS(1008, "Hệ thống không phản hồi", HttpStatus.INTERNAL_SERVER_ERROR),
    ERROR_SAVED(1009, "Lưu thông tin thất bại", HttpStatus.BAD_REQUEST),
    ERROR_MOMO_PAYMENT(1010, "Momo Payment phản hồi không hợp lệ", HttpStatus.BAD_REQUEST),
    ERROR_MOMO_REFUND(1010, "Momo Refund phản hồi không hợp lệ", HttpStatus.BAD_REQUEST),
    ERROR_MOMO_IPN(1011, "Momo không phản hồi IPN", HttpStatus.BAD_REQUEST),
    ERROR_SIGNATURE(1011, "Chữ kí chưa xác thực", HttpStatus.UNAUTHORIZED),


    COMPANY_NOT_EXISTED(4001, "Nhà xe không tồn tại", HttpStatus.BAD_REQUEST),
    EMAIL_EXISTED(4002, "Email này đã được sử dụng", HttpStatus.BAD_REQUEST),
    ACCOUNT_NOT_EXISTED(4003, "Tài khoản không tồn tại", HttpStatus.BAD_REQUEST),
    ACCOUNT_BLOCKED(4004, "Tài khoản đã bị khóa", HttpStatus.FORBIDDEN),
    HOTLINE_EXISTED(4004, "Số hotline đã tồn tại trên hệ thống", HttpStatus.BAD_REQUEST),
    INFO_EXISTED(4005, "Thông tin đã tồn tại", HttpStatus.BAD_REQUEST),
    NOT_EXISTED(4006, "Dữ liệu không tồn tại", HttpStatus.BAD_REQUEST),
    ROUTE_NOT_EXISTED(4007, "Tuyến đường không tồn tại", HttpStatus.BAD_REQUEST),
    INVALID_DEPARTURE_TIME(4008, "Thời gian khởi hành không hợp lệ", HttpStatus.BAD_REQUEST),
    BOOKING_TRIP_INVALID(4008, "Đặt chuyến xe không hợp lệ", HttpStatus.BAD_REQUEST),
    PAYMENT_INVALID(4008, "Không thể thanh toán", HttpStatus.BAD_REQUEST),
    PAYMENT_COMPLETED(4009, "Đơn hàng đã được thanh toán", HttpStatus.BAD_REQUEST),

    INVALID_GMAIL(4021, "Không tìm thấy gmail này trong hệ thống", HttpStatus.BAD_REQUEST),
    INVALID_OTP(4022, "Sai OTP hoặc OTP đã hết hạn", HttpStatus.BAD_REQUEST),
    INVALID_CUSTOMER_REGISTER(4023, "Gmail hoặc số điện thoại đã được sử dụng", HttpStatus.BAD_REQUEST),
    INVALID_FORMAT(4024, "Dữ liệu gửi lên không đúng định dạng", HttpStatus.BAD_REQUEST),
    PHONE_EXISTED(4025, "Số điện thoại này đã được sử dụng", HttpStatus.BAD_REQUEST),
    REGISTRATION_EXPIRED(4026, "Phiên đăng ký đã hết hạn. Vui lòng đăng ký lại", HttpStatus.BAD_REQUEST),
    MAIL_SEND_FAILED(5001, "Hệ thống không thể gửi email xác thực lúc này", HttpStatus.INTERNAL_SERVER_ERROR),
    SYSTEM_ERROR(5000, "Đã xảy ra lỗi hệ thống, vui lòng thử lại sau", HttpStatus.INTERNAL_SERVER_ERROR),
    BUS_BUSY(4009, "Xe đã có lịch trình khác trong khoảng thời gian này", HttpStatus.BAD_REQUEST),
    TRIP_SEAT_BOOKED(4010, "Ghế đã bị đặt", HttpStatus.BAD_REQUEST),
    TRIP_SEAT_INVALID(4011, "Ghế không hợp lệ", HttpStatus.BAD_REQUEST),
    ORDER_EXISTED(4012, "Đơn hàng đã tồn tại", HttpStatus.BAD_REQUEST),
    BOOKING_ANOTHER_ORDER(4013, "Bạn đang xử lí 1 đơn hàng khác", HttpStatus.BAD_REQUEST),
    ROUTE_STOP_INVALID(4014, "Điểm đón trả không hợp lệ", HttpStatus.BAD_REQUEST),
    ROUTE_INVALID(4014, "Tuyến đường không hợp lệ", HttpStatus.BAD_REQUEST),
    TICKET_INVALID(4014, "Vé không hợp lệ", HttpStatus.BAD_REQUEST),
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
