package com.example.BusTicket.util;


import org.apache.commons.codec.binary.Hex;
import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

@Component
public class MomoUtil {
    public String generateSignature(String rawData, String secretKey) {
        try {
            Mac hmacSHA256 = Mac.getInstance("HmacSHA256");
            SecretKeySpec secretKeySpec = new SecretKeySpec(secretKey.getBytes(), "HmacSHA256");
            hmacSHA256.init(secretKeySpec);

            byte[] hash = hmacSHA256.doFinal(rawData.getBytes());
            return Hex.encodeHexString(hash);
        } catch (Exception e) {
            throw new RuntimeException("Error while generating signature", e);
        }
    }
}
