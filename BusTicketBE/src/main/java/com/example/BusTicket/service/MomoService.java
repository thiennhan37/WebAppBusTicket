package com.example.BusTicket.service;

import com.example.BusTicket.configuration.MomoConfiguration;
import com.example.BusTicket.dto.general.ExtraDataDTO;
import com.example.BusTicket.dto.request.MomoPaymentRequest;
import com.example.BusTicket.dto.request.MomoRefundRequest;
import com.example.BusTicket.dto.response.MomoPaymentResponse;
import com.example.BusTicket.dto.response.MomoRefundResponse;
import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.enums.MomoEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.repository.jpa.BookingOrderRepository;
import com.example.BusTicket.util.MomoUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MomoService{
    private final MomoConfiguration momoConfiguration;
    private final MomoUtil momoUtil;
    private final BookingOrderRepository bookingOrderRepository;
    private final RestTemplate restTemplate = new RestTemplate();


    private final String PAYMENT_PREFIX = "PAYMENT_";
    private final String REFUND_PREFIX = "REFUND_";

    public MomoPaymentResponse createMomoPayment(MomoPaymentRequest request) {
        String requestId = UUID.randomUUID().toString();
        String orderId = UUID.randomUUID().toString();

        String bookingOrderId = request.getBookingOrderId();
        String paymentId = request.getPaymentId();
        BookingOrder bookingOrder = bookingOrderRepository.findById(bookingOrderId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        Long amount = bookingOrder.getTotalCost();
        String orderInfo = request.getOrderInfo();
        ExtraDataDTO extraDataDTO = ExtraDataDTO.builder()
                .type(MomoEnum.PAYMENT.name())
                .bookingOrderId(bookingOrderId)
                .paymentId(paymentId)
                .build();
        String extraData = momoUtil.buildExtraData(extraDataDTO);

        String rawData = "accessKey=" + momoConfiguration.getAccessKey()
                + "&amount=" + amount
                + "&extraData=" + extraData
                + "&ipnUrl=" + momoConfiguration.getIpnUrl()
                + "&orderId=" + orderId
                + "&orderInfo=" + orderInfo
                + "&partnerCode=" + momoConfiguration.getPartnerCode()
                + "&redirectUrl=" + momoConfiguration.getRedirectUrl()
                + "&requestId=" + requestId
                + "&requestType=captureWallet";

//        System.out.println("rawData: " + rawData);
        String signature = momoUtil.generateSignature(rawData, momoConfiguration.getSecretKey());

        Map<String, Object> body = new HashMap<>();
        body.put("partnerCode", momoConfiguration.getPartnerCode());
        body.put("accessKey", momoConfiguration.getAccessKey());
        body.put("requestId", requestId);
        body.put("amount", amount);
        body.put("orderId", orderId);
        body.put("orderInfo", orderInfo);
        body.put("redirectUrl", momoConfiguration.getRedirectUrl());
        body.put("ipnUrl", momoConfiguration.getIpnUrl());
        body.put("extraData", extraData);
        body.put("requestType", "captureWallet");
        body.put("signature", signature);
        body.put("lang", "vi");

        // nhận repsonse từ endpoint thanh toán của momo
        ResponseEntity<Map> response = restTemplate.postForEntity(
                momoConfiguration.getEndpoint(),
                body,
                Map.class
        );

        Map<String, Object> result = response.getBody();

        if (result == null || !result.containsKey("payUrl")) {
            if(result != null) System.out.println(result.get("message"));
            throw new MyAppException(ErrorCode.ERROR_MOMO_PAYMENT);
        }
        return MomoPaymentResponse.builder()
                .payUrl((String) result.get("payUrl"))
                .qrCodeUrl((String) result.get("qrCodeUrl"))
                .build();
    }

    public MomoRefundResponse createMomoRefund(MomoRefundRequest request) {
        String requestId = UUID.randomUUID().toString();
        String orderId = UUID.randomUUID().toString();
        String transId = request.getTransId().toString();
        String amount = request.getAmount().toString();
        String description = request.getDescription();

        String rawData = "accessKey=" + momoConfiguration.getAccessKey() +
                "&amount=" + amount +
                "&description=" + description +
                "&orderId=" + orderId +
                "&partnerCode=" + momoConfiguration.getPartnerCode() +
                "&requestId=" + requestId +
                "&transId=" + transId;
        String signature = momoUtil.generateSignature(rawData, momoConfiguration.getSecretKey());

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("partnerCode", momoConfiguration.getPartnerCode());
        requestBody.put("orderId", orderId);
        requestBody.put("requestId", requestId);
        requestBody.put("amount", amount);
        requestBody.put("transId", transId);
        requestBody.put("orderInfo", description);
        requestBody.put("description", description);
        requestBody.put("signature", signature);
        requestBody.put("lang", "vi");

        // nhận repsonse từ endpoint refund của momo
        ResponseEntity<Map> response = restTemplate.postForEntity(
                momoConfiguration.getRefundUrl(),
                requestBody,
                Map.class
        );

        Map<String, Object> result = response.getBody();
        if (result == null) {
            throw new MyAppException(ErrorCode.ERROR_MOMO_REFUND);
        }
        return MomoRefundResponse.builder()
                .momoOrderId(result.get("orderId").toString())
                .resultCode(Long.valueOf(result.get("resultCode").toString()))
                .transId(Long.valueOf(result.get("transId").toString()))
                .build();
    }


}
