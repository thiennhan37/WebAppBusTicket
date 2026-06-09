package com.example.BusTicket.service;

import com.example.BusTicket.configuration.VNPayConfig;
import com.example.BusTicket.dto.request.VNPayPaymentRequest;
import com.example.BusTicket.dto.response.VNPayPaymentResponse;
import com.example.BusTicket.dto.response.VNPayRefundResponse;
import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.enums.AccountType;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.repository.jpa.BookingOrderRepository;
import com.example.BusTicket.util.VNPayUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class VNPayService {

    private static final String REFUND_API_VERSION = "2.1.0";

    private final VNPayConfig vnPayConfig;
    private final VNPayUtil vnPayUtil;
    private final BookingOrderRepository bookingOrderRepository;
    private final ObjectMapper objectMapper;
    private final RestTemplate restTemplate = new RestTemplate();

    /**
     * Tạo URL thanh toán VNPay.
     * paymentId được dùng làm vnp_TxnRef (mã giao dịch merchant) để trace callback.
     */
    public VNPayPaymentResponse createVNPayPayment(VNPayPaymentRequest request, AccountType type,
                                                    String ipAddress) {
        String bookingOrderId = request.getBookingOrderId();
        String paymentId = request.getPaymentId();

        BookingOrder bookingOrder = bookingOrderRepository.findById(bookingOrderId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));

        // VNPay yêu cầu amount tính bằng đơn vị VND × 100
        long amount = bookingOrder.getTotalCost() * 100L;

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime expireTime = now.plusMinutes(15);

        Map<String, String> params = new HashMap<>();
        params.put("vnp_Version",    vnPayConfig.getVersion());
        params.put("vnp_Command",    vnPayConfig.getCommand());
        params.put("vnp_TmnCode",    vnPayConfig.getTmnCode());
        params.put("vnp_Amount",     String.valueOf(amount));
        params.put("vnp_CurrCode",   "VND");
        // vnp_TxnRef = paymentId → dùng để lookup Payment khi nhận IPN
        params.put("vnp_TxnRef",     paymentId);
        params.put("vnp_OrderInfo",  request.getOrderInfo());
        params.put("vnp_OrderType",  vnPayConfig.getOrderType());
        params.put("vnp_Locale",     "vn");
        params.put("vnp_ReturnUrl",  vnPayConfig.getReturnUrl());
        params.put("vnp_IpAddr",     ipAddress != null ? ipAddress : "127.0.0.1");
        String createDate = vnPayUtil.formatDateTime(now);
        params.put("vnp_CreateDate", createDate);
        params.put("vnp_ExpireDate", vnPayUtil.formatDateTime(expireTime));

        // Build hash data (sorted, URL-encoded) và ký
        String hashData = vnPayUtil.buildHashData(params);
        String signature = vnPayUtil.generateSignature(hashData, vnPayConfig.getHashSecret());

        // Build query string đầy đủ (bao gồm cả chữ ký)
        params.put("vnp_SecureHash", signature);
        String queryString = vnPayUtil.buildQueryString(params);
        String payUrl = vnPayConfig.getPayUrl() + "?" + queryString;

        log.info("VNPay payment URL created for paymentId={}, bookingOrderId={}, type={}",
                paymentId, bookingOrderId, type.name());

        return VNPayPaymentResponse.builder()
                .payUrl(payUrl)
                .vnpCreateDate(createDate)
                .build();
    }


    /**
     * Gọi API hoàn tiền VNPay.
     * VNPay Refund API v2.1.0 – POST application/json.
     *
     * @param transactionDate vnp_CreateDate của giao dịch thanh toán gốc (yyyyMMddHHmmss, GMT+7)
     */
    public VNPayRefundResponse createVNPayRefund(String vnpTxnRef, Long amount,
                                                  String transactionNo, String transactionDate,
                                                  String orderInfo, String ipAddress) {
        String requestId = vnPayUtil.generateRefundRequestId();
        String createDate = vnPayUtil.currentDateTimeGmt7();
        String txnNo = transactionNo != null ? transactionNo : "";
        String sanitizedOrderInfo = vnPayUtil.sanitizeOrderInfo(orderInfo);

        Map<String, String> hashParams = new LinkedHashMap<>();
        hashParams.put("vnp_RequestId",       requestId);
        hashParams.put("vnp_Version",         REFUND_API_VERSION);
        hashParams.put("vnp_Command",         "refund");
        hashParams.put("vnp_TmnCode",         vnPayConfig.getTmnCode());
        hashParams.put("vnp_TransactionType", "02");
        hashParams.put("vnp_TxnRef",          vnpTxnRef);
        hashParams.put("vnp_Amount",          String.valueOf(amount * 100L));
        hashParams.put("vnp_OrderInfo",       sanitizedOrderInfo);
        hashParams.put("vnp_TransactionNo",   txnNo);
        hashParams.put("vnp_TransactionDate", transactionDate);
        hashParams.put("vnp_CreateBy",        "BusTicketSystem");
        hashParams.put("vnp_CreateDate",      createDate);
        hashParams.put("vnp_IpAddr",          ipAddress != null ? ipAddress : "127.0.0.1");

        String rawHash = vnPayUtil.buildRefundHashData(hashParams);
        String signature = vnPayUtil.generateSignature(rawHash, vnPayConfig.getHashSecret());
        hashParams.put("vnp_SecureHash", signature);

        Map<String, Object> jsonBody = vnPayUtil.buildRefundJsonBody(hashParams);

        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            String jsonPayload = objectMapper.writeValueAsString(jsonBody);
            HttpEntity<String> entity = new HttpEntity<>(jsonPayload, headers);

            log.info("Calling VNPay refund API url={} body={}", vnPayConfig.getRefundUrl(), jsonPayload);
            ResponseEntity<Map> response = restTemplate.postForEntity(
                    vnPayConfig.getRefundUrl(), entity, Map.class);
            log.info("VNPay refund API response status={}, body={}", response.getStatusCode(), response.getBody());
            Map<String, Object> result = response.getBody();

            if (result == null) {
                throw new MyAppException(ErrorCode.ERROR_VNPAY_REFUND);
            }

            String responseCode = resolveResponseCode(result);
            String returnTxnRef = stringValue(result.get("vnp_TxnRef"), vnpTxnRef);
            String responseTxnNo = stringValue(result.get("vnp_TransactionNo"), "");
            String message = stringValue(result.get("vnp_Message"),
                    stringValue(result.get("Message"), ""));

            log.info("VNPay refund result: code={}, txnRef={}, message={}", responseCode, returnTxnRef, message);

            return VNPayRefundResponse.builder()
                    .vnpTxnRef(returnTxnRef)
                    .responseCode(responseCode)
                    .transactionNo(responseTxnNo)
                    .message(message)
                    .build();
        } catch (MyAppException e) {
            throw e;
        } catch (Exception e) {
            log.error("VNPay refund API error: {}", e.getMessage(), e);
            throw new MyAppException(ErrorCode.ERROR_VNPAY_REFUND);
        }
    }

    private String resolveResponseCode(Map<String, Object> result) {
        if (result.containsKey("vnp_ResponseCode")) {
            return result.get("vnp_ResponseCode").toString();
        }
        if (result.containsKey("RspCode")) {
            return result.get("RspCode").toString();
        }
        return "99";
    }

    private String stringValue(Object value, String defaultValue) {
        return value != null ? value.toString() : defaultValue;
    }
}
