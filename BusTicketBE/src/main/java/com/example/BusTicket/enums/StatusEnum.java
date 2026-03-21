package com.example.BusTicket.enums;

import lombok.Getter;

@Getter
public enum StatusEnum {
    ACTIVE("Tài khoản đang hoạt động"),
    BLOCKED("Tài khoản bị khóa"),
    ;
    private String description;

    StatusEnum(String description) {
        this.description = description;
    }
}
