package com.example.BusTicket.controller.order;

import com.example.BusTicket.configuration.MomoConfiguration;
import com.example.BusTicket.dto.general.ExtraDataDTO;
import com.example.BusTicket.dto.request.MomoCreateRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.MomoCreateResponse;
import com.example.BusTicket.enums.MomoIpnEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.service.PaymentService;
import com.example.BusTicket.util.MomoUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/momo")
@RequiredArgsConstructor
public class PaymentController {
    private final PaymentService paymentService;
    private final MomoUtil momoUtil;
    private final MomoConfiguration momoConfiguration;
    @PostMapping("/payment")
    ApiResponse<MomoCreateResponse> createPayment(@RequestBody MomoCreateRequest request) {
        return ApiResponse.success(paymentService.createMomoPayment(request));
    }
    @PostMapping("/ipn")
    public ApiResponse<Boolean> handleMomoIPN(@RequestBody Map<String, Object> payload) {

        String resultCode = payload.get("resultCode").toString();
        String orderId = payload.get("orderId").toString();
        ExtraDataDTO extraDataDTO = momoUtil.parseExtraData(payload.get("extraData").toString());
        boolean result = false;
        if( !momoUtil.verifySignature(payload, momoConfiguration.getSecretKey()))
            throw new MyAppException(ErrorCode.ERROR_SIGNATURE);
        if ("0".equals(resultCode)) {
            System.out.println("thanh cong");
            result = true;
        }
        String type = extraDataDTO.getType();
        if(type.equals(MomoIpnEnum.PAYMENT_TICKET.name())){
            System.out.println("do ticket service");
        }
        else{
            System.out.println("co loi extraData");
        }

        return ApiResponse.success(result);
    }

}
