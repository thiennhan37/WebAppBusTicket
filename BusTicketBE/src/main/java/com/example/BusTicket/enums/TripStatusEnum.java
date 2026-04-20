package com.example.BusTicket.enums;

import lombok.Getter;

@Getter
public enum TripStatusEnum {
    SCHEDULED("Đang lên lịch"),
    OPEN("Đang hoạt động"),
    CLOSED("Đã đóng"),
    CANCELLED("Đã hủy"),
    ;
    private String description;

    TripStatusEnum(String description) {
        this.description = description;
    }
}
