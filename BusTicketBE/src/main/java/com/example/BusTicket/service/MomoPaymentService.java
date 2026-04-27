package com.example.BusTicket.service;

import com.example.BusTicket.configuration.MomoConfiguration;
import com.example.BusTicket.dto.general.ExtraDataDTO;
import com.example.BusTicket.dto.request.MomoCreateRequest;
import com.example.BusTicket.dto.response.MomoCreateResponse;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
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
public class MomoPaymentService implements PaymentService{
    private final MomoConfiguration momoConfiguration;
    private final MomoUtil momoUtil;
    private final RestTemplate restTemplate = new RestTemplate();
    @Override
    public MomoCreateResponse createMomoPayment(MomoCreateRequest request) {
        String requestId = UUID.randomUUID().toString();
        String orderId = request.getOrderId();
        String amount = request.getAmount();
        String orderInfo = request.getOrderInfo();
        ExtraDataDTO extraDataDTO = ExtraDataDTO.builder()
                .type(request.getType())
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
            throw new MyAppException(ErrorCode.ERROR_MOMO);
        }
        return MomoCreateResponse.builder()
                .payUrl((String) result.get("payUrl"))
                .qrCodeUrl((String) result.get("qrCodeUrl"))
                .build();
    }

}
