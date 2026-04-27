package com.example.BusTicket.service;

import com.example.BusTicket.dto.request.MomoCreateRequest;
import com.example.BusTicket.dto.response.MomoCreateResponse;
import org.springframework.stereotype.Service;

@Service
public interface PaymentService {
    MomoCreateResponse createMomoPayment(MomoCreateRequest request);
}
