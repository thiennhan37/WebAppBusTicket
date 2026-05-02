package com.example.BusTicket.service;

import com.example.BusTicket.dto.request.PaymentRequest;
import com.example.BusTicket.dto.response.PaymentResponse;
import com.example.BusTicket.entity.Payment;
import com.example.BusTicket.mapper.PaymentMapper;
import com.example.BusTicket.repository.jpa.PaymentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class PaymentService {
    private final PaymentRepository paymentRepository;
    private final PaymentMapper paymentMapper;


    public PaymentResponse createPayment(PaymentRequest request){
        Payment payment = paymentMapper.toPayment(request);
        payment.setCreatedAt(LocalDateTime.now());
        paymentRepository.save(payment);
        return paymentMapper.toPaymentResponse(payment);

    }
}
