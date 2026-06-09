package com.example.BusTicket.util;

import com.example.BusTicket.configuration.VNPayConfig;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.TreeMap;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class VNPayUtil {

    private static final ZoneId VNPAY_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final DateTimeFormatter VNPAY_DATE_FORMAT =
            DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

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
     * Format datetime theo chuẩn VNPay: yyyyMMddHHmmss (GMT+7)
     */
    public String formatDateTime(LocalDateTime dateTime) {
        return dateTime.atZone(ZoneId.systemDefault())
                .withZoneSameInstant(VNPAY_ZONE)
                .format(VNPAY_DATE_FORMAT);
    }

    public String currentDateTimeGmt7() {
        return ZonedDateTime.now(VNPAY_ZONE).format(VNPAY_DATE_FORMAT);
    }

    public String generateRefundRequestId() {
        return UUID.randomUUID().toString().replace("-", "").substring(0, 32);
    }

    /**
     * Checksum refund API v2.1.0:
     * RequestId|Version|Command|TmnCode|TransactionType|TxnRef|Amount|TransactionNo|
     * TransactionDate|CreateBy|CreateDate|IpAddr|OrderInfo
     */
    public String buildRefundHashData(Map<String, String> params) {
        return params.get("vnp_RequestId") + "|" +
                params.get("vnp_Version") + "|" +
                params.get("vnp_Command") + "|" +
                params.get("vnp_TmnCode") + "|" +
                params.get("vnp_TransactionType") + "|" +
                params.get("vnp_TxnRef") + "|" +
                params.get("vnp_Amount") + "|" +
                params.getOrDefault("vnp_TransactionNo", "") + "|" +
                params.get("vnp_TransactionDate") + "|" +
                params.get("vnp_CreateBy") + "|" +
                params.get("vnp_CreateDate") + "|" +
                params.get("vnp_IpAddr") + "|" +
                params.get("vnp_OrderInfo");
    }

    /**
     * Build JSON body theo tài liệu VNPay refund API:
     * các trường Numeric phải là số trong JSON, không phải chuỗi.
     */
    public Map<String, Object> buildRefundJsonBody(Map<String, String> hashParams) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("vnp_RequestId", hashParams.get("vnp_RequestId"));
        body.put("vnp_Version", hashParams.get("vnp_Version"));
        body.put("vnp_Command", hashParams.get("vnp_Command"));
        body.put("vnp_TmnCode", hashParams.get("vnp_TmnCode"));
        body.put("vnp_TransactionType", hashParams.get("vnp_TransactionType"));
        body.put("vnp_TxnRef", hashParams.get("vnp_TxnRef"));
        body.put("vnp_Amount", Long.parseLong(hashParams.get("vnp_Amount")));
        body.put("vnp_OrderInfo", hashParams.get("vnp_OrderInfo"));

        String txnNo = hashParams.getOrDefault("vnp_TransactionNo", "");
        if (!txnNo.isEmpty()) {
            body.put("vnp_TransactionNo", Long.parseLong(txnNo));
        }

        body.put("vnp_TransactionDate", Long.parseLong(hashParams.get("vnp_TransactionDate")));
        body.put("vnp_CreateBy", hashParams.get("vnp_CreateBy"));
        body.put("vnp_CreateDate", Long.parseLong(hashParams.get("vnp_CreateDate")));
        body.put("vnp_IpAddr", hashParams.get("vnp_IpAddr"));
        body.put("vnp_SecureHash", hashParams.get("vnp_SecureHash"));
        return body;
    }

    /** vnp_OrderInfo chỉ cho phép ký tự alphanumeric */
    public String sanitizeOrderInfo(String orderInfo) {
        if (orderInfo == null) return "";
        return orderInfo.replaceAll("[^a-zA-Z0-9 ]", "").trim();
    }
}
