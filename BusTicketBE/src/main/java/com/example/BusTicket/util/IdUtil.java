package com.example.BusTicket.util;

import com.aventrix.jnanoid.jnanoid.NanoIdUtils;

import java.time.Instant;
import java.util.Random;


public class IdUtil {
    private static final String charString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    private static final String numberString = "123456789";
    private static final String alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    public static String generateID(){
//        Random random = new Random();
//        Long mlsValue = Instant.now().toEpochMilli();
//        StringBuilder sb = new StringBuilder();
//        sb.append(charString.charAt(random.nextInt(26)) );
//        sb.append(numberString.charAt(random.nextInt(9)) );
//        sb.append(Long.toString(mlsValue, 36).toUpperCase());
//
//        return sb.toString();

        String id = NanoIdUtils.randomNanoId(
                NanoIdUtils.DEFAULT_NUMBER_GENERATOR,
                alphabet.toCharArray(),
                10);
        return id;
    }
}
