package com.example.BusTicket.controller.customer;

import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.MomoPaymentResponse;
import com.example.BusTicket.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class CustomerPaymentController {
    private final PaymentService paymentService;

}
