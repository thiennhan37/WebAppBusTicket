package com.example.BusTicket.controller.order;

import com.example.BusTicket.configuration.MomoConfiguration;
import com.example.BusTicket.dto.general.ExtraDataDTO;
import com.example.BusTicket.dto.request.MomoPaymentRequest;
import com.example.BusTicket.dto.request.MomoRefundRequest;
import com.example.BusTicket.dto.request.PaymentRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.MomoPaymentResponse;
import com.example.BusTicket.dto.response.MomoRefundResponse;
import com.example.BusTicket.enums.MomoIpnEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.service.MomoService;
import com.example.BusTicket.service.PaymentService;
import com.example.BusTicket.util.MomoUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/momo")
@RequiredArgsConstructor
public class PaymentController {
    private final MomoService momoService;
    private final MomoUtil momoUtil;
    private final MomoConfiguration momoConfiguration;
    private final PaymentService paymentService;

    @PostMapping("/payment")
    ApiResponse<MomoPaymentResponse> createPayment(@RequestBody MomoPaymentRequest request) {
        return ApiResponse.success(momoService.createMomoPayment(request));
    }
    @PostMapping("/refund")
    ApiResponse<MomoRefundResponse> createRefund(@RequestBody MomoRefundRequest request) {
        return ApiResponse.success(momoService.createMomoRefund(request));
    }
    @PostMapping("/ipn")
    public ApiResponse<Boolean> handleMomoIPN(@RequestBody Map<String, Object> payload) {

        String resultCode = payload.get("resultCode").toString();
        String orderId = payload.get("orderId").toString();
//        ExtraDataDTO extraDataDTO = momoUtil.parseExtraData(payload.get("extraData").toString());
        boolean result = false;
        if( !momoUtil.verifySignature(payload, momoConfiguration.getSecretKey()))
            throw new MyAppException(ErrorCode.ERROR_SIGNATURE);
        if ("0".equals(resultCode)) {
            System.out.println("thanh cong");
            result = true;
        }
        for(String key : payload.keySet()){
            System.out.println(key + ": " + payload.get(key).toString());
        }
        String type = orderId.split("_")[0];
        String bookingOrderId = orderId.split("_")[1];
        PaymentRequest request = PaymentRequest.builder()
                .requestId(payload.get("requestId").toString())
                .bookingOrderId(bookingOrderId)
                .transId(Long.valueOf(payload.get("transId").toString()))
                .type(type)
                .build();
        System.out.println(request.getTransId());
        if(type.equals(MomoIpnEnum.PAYMENT.name())){
            paymentService.createPayment(request);
            System.out.println("payment ticket service");
        }
        else if(type.equals(MomoIpnEnum.REFUND.name()) ){
            System.out.println("refund ticket service");
        }
        else{
            System.out.println("co loi extraData");
        }
        return ApiResponse.success(result);
    }

}
