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
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;

@Service
@RequiredArgsConstructor
@Slf4j
public class VNPayService {

    private final VNPayConfig vnPayConfig;
    private final VNPayUtil vnPayUtil;
    private final BookingOrderRepository bookingOrderRepository;
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
        params.put("vnp_CreateDate", vnPayUtil.formatDateTime(now));
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
                .build();
    }


    /**
     * Gọi API hoàn tiền VNPay.
     * VNPay Refund API v2.1.0 – POST JSON.
     */
    public VNPayRefundResponse createVNPayRefund(String vnpTxnRef, Long amount,
                                                  String transactionNo, String orderInfo,
                                                  String ipAddress) {
        LocalDateTime now = LocalDateTime.now();
        String requestId = String.valueOf(System.currentTimeMillis());

        Map<String, String> params = new TreeMap<>();
        params.put("vnp_RequestId",       requestId);
        params.put("vnp_Version",         vnPayConfig.getVersion());
        params.put("vnp_Command",         "refund");
        params.put("vnp_TmnCode",         vnPayConfig.getTmnCode());
        params.put("vnp_TransactionType", "02"); // 02 = hoàn toàn bộ
        params.put("vnp_TxnRef",          vnpTxnRef);
        params.put("vnp_Amount",          String.valueOf(amount * 100L));
        params.put("vnp_OrderInfo",       orderInfo);
        params.put("vnp_TransactionNo",   transactionNo != null ? transactionNo : "");
        params.put("vnp_TransactionDate", vnPayUtil.formatDateTime(now));
        params.put("vnp_CreateBy",        "BusTicketSystem");
        params.put("vnp_CreateDate",      vnPayUtil.formatDateTime(now));
        params.put("vnp_IpAddr",          ipAddress != null ? ipAddress : "127.0.0.1");

        // Hash theo thứ tự VNPay quy định: RequestId|Version|Command|TmnCode|TransactionType|TxnRef|Amount|TransactionNo|TransactionDate|CreateBy|CreateDate|IpAddr|OrderInfo
        String rawHash = params.get("vnp_RequestId") + "|" +
                params.get("vnp_Version") + "|" +
                params.get("vnp_Command") + "|" +
                params.get("vnp_TmnCode") + "|" +
                params.get("vnp_TransactionType") + "|" +
                params.get("vnp_TxnRef") + "|" +
                params.get("vnp_Amount") + "|" +
                params.get("vnp_TransactionNo") + "|" +
                params.get("vnp_TransactionDate") + "|" +
                params.get("vnp_CreateBy") + "|" +
                params.get("vnp_CreateDate") + "|" +
                params.get("vnp_IpAddr") + "|" +
                params.get("vnp_OrderInfo");

        String signature = vnPayUtil.generateSignature(rawHash, vnPayConfig.getHashSecret());
        params.put("vnp_SecureHash", signature);

        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(
                    vnPayConfig.getRefundUrl(), params, Map.class);
            Map<String, Object> result = response.getBody();

            if (result == null) {
                throw new MyAppException(ErrorCode.ERROR_VNPAY_REFUND);
            }

            String responseCode = result.getOrDefault("vnp_ResponseCode", "99").toString();
            String returnTxnRef = result.getOrDefault("vnp_TxnRef", vnpTxnRef).toString();
            String txnNo = result.getOrDefault("vnp_TransactionNo", "").toString();
            String message = result.getOrDefault("vnp_Message", "").toString();

            log.info("VNPay refund result: code={}, txnRef={}, message={}", responseCode, returnTxnRef, message);

            return VNPayRefundResponse.builder()
                    .vnpTxnRef(returnTxnRef)
                    .responseCode(responseCode)
                    .transactionNo(txnNo)
                    .message(message)
                    .build();
        } catch (MyAppException e) {
            throw e;
        } catch (Exception e) {
            log.error("VNPay refund API error: {}", e.getMessage(), e);
            throw new MyAppException(ErrorCode.ERROR_VNPAY_REFUND);
        }
    }
}
