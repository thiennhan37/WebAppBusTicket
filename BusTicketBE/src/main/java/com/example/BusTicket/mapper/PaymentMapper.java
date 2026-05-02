package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.request.PaymentRequest;
import com.example.BusTicket.dto.response.PaymentResponse;
import com.example.BusTicket.dto.response.TripSeatResponse;
import com.example.BusTicket.entity.Payment;
import com.example.BusTicket.entity.TripSeat;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring", uses = {})
public interface PaymentMapper {
    Payment toPayment(PaymentRequest request);
    PaymentResponse toPaymentResponse(Payment payment);

}
