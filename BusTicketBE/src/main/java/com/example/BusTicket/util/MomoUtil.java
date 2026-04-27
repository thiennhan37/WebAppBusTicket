package com.example.BusTicket.util;


import com.example.BusTicket.dto.general.ExtraDataDTO;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.codec.binary.Hex;
import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.util.Base64;
import java.util.Map;

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
    public boolean verifySignature(Map<String, Object> payload, String secretKey) {
        String rawData =
                "accessKey=" + payload.get("accessKey") +
                "&amount=" + payload.get("amount") +
                "&extraData=" + payload.get("extraData") +
                "&message=" + payload.get("message") +
                "&orderId=" + payload.get("orderId") +
                "&orderInfo=" + payload.get("orderInfo") +
                "&orderType=" + payload.get("orderType") +
                "&partnerCode=" + payload.get("partnerCode") +
                "&payType=" + payload.get("payType") +
                "&requestId=" + payload.get("requestId") +
                "&responseTime=" + payload.get("responseTime") +
                "&resultCode=" + payload.get("resultCode") +
                "&transId=" + payload.get("transId");

        String expectedSignature = generateSignature(rawData, secretKey);
        String signature = payload.get("signature").toString();
        return expectedSignature.equals(signature);
    }
    public String buildExtraData(Object data) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            String json = mapper.writeValueAsString(data);
            return Base64.getEncoder().encodeToString(json.getBytes());
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
    public ExtraDataDTO parseExtraData(String extraData) {
        try {
            String json = new String(Base64.getDecoder().decode(extraData));
            ObjectMapper mapper = new ObjectMapper();
            return mapper.readValue(json, ExtraDataDTO.class);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
