package com.example.BusTicket.enums;

import lombok.Getter;

@Getter
public enum GenderEnum {
    MALE("Nam"),
    FEMALE("Nữ"),
    OTHER("Khác");

    private final String description;

    GenderEnum(String description) {
        this.description = description;
    }
}