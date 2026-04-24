package com.example.BusTicket.service;

import com.example.BusTicket.configuration.MomoConfiguration;
import com.example.BusTicket.dto.request.MomoCreateRequest;
import com.example.BusTicket.dto.response.MomoCreateResponse;
import com.example.BusTicket.util.MomoUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.web.client.RestTemplate;

@RequiredArgsConstructor
public class MomoPaymentService implements PaymentService{
    private final MomoConfiguration momoConfiguration;
    private final MomoUtil momoUtil;
    private final RestTemplate restTemplate = new RestTemplate();
    @Override
    public MomoCreateResponse createMomoPayment(MomoCreateRequest request) {
        return null;
    }
}
