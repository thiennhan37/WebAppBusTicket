package com.example.BusTicket.util;

import java.time.Instant;
import java.util.Random;


public class IdUtil {
    private static final String charString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    private static final String numberString = "123456789";

    public static String generateID(){
        Random random = new Random();
        Long mlsValue = Instant.now().toEpochMilli();
        StringBuilder sb = new StringBuilder();
        sb.append(charString.charAt(random.nextInt(26)) );
        sb.append(numberString.charAt(random.nextInt(9)) );
        sb.append(Long.toString(mlsValue, 36).toUpperCase());

        return sb.toString();
    }
}
