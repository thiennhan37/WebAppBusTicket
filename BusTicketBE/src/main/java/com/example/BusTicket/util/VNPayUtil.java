package com.example.BusTicket.util;

import com.example.BusTicket.configuration.VNPayConfig;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.TreeMap;

@Component
@RequiredArgsConstructor
public class VNPayUtil {

    private final VNPayConfig vnPayConfig;

    /**
     * Tạo chữ ký HMAC-SHA512 cho VNPay
     */
    public String generateSignature(String rawData, String secretKey) {
        try {
            Mac hmacSHA512 = Mac.getInstance("HmacSHA512");
            SecretKeySpec secretKeySpec = new SecretKeySpec(
                    secretKey.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
            hmacSHA512.init(secretKeySpec);
            byte[] hash = hmacSHA512.doFinal(rawData.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            throw new RuntimeException("Error generating VNPay signature", e);
        }
    }

    /**
     * Build query string đã sắp xếp theo key (alphabetically) + URL-encode value
     * VNPay yêu cầu params phải sorted trước khi ký
     */
    public String buildQueryString(Map<String, String> params) {
        StringBuilder sb = new StringBuilder();
        // TreeMap tự sort theo key alphabetically
        TreeMap<String, String> sorted = new TreeMap<>(params);
        for (Map.Entry<String, String> entry : sorted.entrySet()) {
            if (entry.getValue() != null && !entry.getValue().isEmpty()) {
                if (sb.length() > 0) sb.append("&");
                sb.append(URLEncoder.encode(entry.getKey(), StandardCharsets.US_ASCII));
                sb.append("=");
                sb.append(URLEncoder.encode(entry.getValue(), StandardCharsets.US_ASCII));
            }
        }
        return sb.toString();
    }

    /**
     * Build raw data (không encode) để ký chữ ký
     * Giống buildQueryString nhưng không URL-encode key, chỉ encode value
     */
    public String buildHashData(Map<String, String> params) {
        StringBuilder sb = new StringBuilder();
        TreeMap<String, String> sorted = new TreeMap<>(params);
        for (Map.Entry<String, String> entry : sorted.entrySet()) {
            if (entry.getValue() != null && !entry.getValue().isEmpty()) {
                if (sb.length() > 0) sb.append("&");
                sb.append(entry.getKey());
                sb.append("=");
                sb.append(URLEncoder.encode(entry.getValue(), StandardCharsets.US_ASCII));
            }
        }
        return sb.toString();
    }

    /**
     * Xác thực chữ ký IPN từ VNPay (GET query params)
     * Loại bỏ vnp_SecureHash và vnp_SecureHashType trước khi tính lại hash
     */
    public boolean verifySignature(Map<String, String> params, String secretKey) {
        String receivedHash = params.get("vnp_SecureHash");
        if (receivedHash == null) return false;

        // Clone map và loại bỏ các field không dùng để hash
        TreeMap<String, String> signParams = new TreeMap<>(params);
        signParams.remove("vnp_SecureHash");
        signParams.remove("vnp_SecureHashType");

        String hashData = buildHashData(signParams);
        String expectedHash = generateSignature(hashData, secretKey);
        return expectedHash.equalsIgnoreCase(receivedHash);
    }

    /**
     * Format datetime theo chuẩn VNPay: yyyyMMddHHmmss
     */
    public String formatDateTime(LocalDateTime dateTime) {
        return dateTime.format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
    }
}
