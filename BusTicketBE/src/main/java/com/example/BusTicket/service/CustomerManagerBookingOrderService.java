package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.*;
import com.example.BusTicket.dto.response.BookingOrderResponse;
import com.example.BusTicket.dto.response.CustomerOrderHistoryResponse;
import com.example.BusTicket.dto.response.MomoPaymentResponse;
import com.example.BusTicket.entity.*;
import com.example.BusTicket.enums.*;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.BookingOrderMapper;
import com.example.BusTicket.repository.jpa.*;
import com.example.BusTicket.util.IdUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Slf4j
@Service
@RequiredArgsConstructor
public class CustomerManagerBookingOrderService {
    private final CustomerRepository customerRepository;
    private final BookingOrderRepository bookingOrderRepository;
    private final TicketRepository ticketRepository;
    private final RedisTemplate<String, String> redisTemplate;
    private final SeatReservationService seatReservationService;
    private final TripSeatRepository tripSeatRepository;

    @Value("${booking.customerHoldingSeatPrefixKey}")
    private String CUSTOMER_HOLD_INFO_PREFIX;

    public List<CustomerOrderHistoryResponse> getRecentOrdersForCustomer() {
        Jwt jwt = JwtHelper.getJwt();
        Customer customer = customerRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));

        LocalDateTime fromTime = LocalDateTime.now().minusMonths(3);
        List<BookingOrder> orders = bookingOrderRepository.findRecentOrdersByCustomerId(customer.getId(), fromTime);
        if (orders.isEmpty()) return List.of();

        List<String> orderIds = orders.stream().map(BookingOrder::getId).toList();
        java.util.Map<String, List<Ticket>> ticketsByOrderId = ticketRepository.findAllByBookingOrderIds(orderIds)
                .stream()
                .collect(java.util.stream.Collectors.groupingBy(t -> t.getBookingOrder().getId()));

        return orders.stream().map(order -> {
            List<Ticket> tickets = ticketsByOrderId.getOrDefault(order.getId(), List.of());
            String orderStatus;
            boolean hasTicket = !tickets.isEmpty();
            boolean allCancelled = hasTicket && tickets.stream().allMatch(t -> TicketStatusEnum.CANCELLED.name().equals(t.getStatus()));
            boolean hasHolding = tickets.stream().anyMatch(t -> TicketStatusEnum.HOLDING.name().equals(t.getStatus()));
            boolean hasPaid = tickets.stream().anyMatch(t -> TicketStatusEnum.PAID.name().equals(t.getStatus()));
            boolean hasExpired = tickets.stream().anyMatch(t -> TicketStatusEnum.EXPIRED.name().equals(t.getStatus()));

            if (allCancelled) {
                orderStatus = TicketStatusEnum.CANCELLED.name();
            } else if (hasHolding) {
                orderStatus = TicketStatusEnum.HOLDING.name();
            } else if (hasPaid) {
                orderStatus = TicketStatusEnum.PAID.name();
            } else if (hasExpired) {
                orderStatus = TicketStatusEnum.EXPIRED.name();
            } else {
                orderStatus = TicketStatusEnum.EXPIRED.name();
            }

            return CustomerOrderHistoryResponse.builder()
                    .orderId(order.getId())
                    .departureProvince(order.getTrip().getRoute().getArrivalProvince().getName())
                    .destinationProvince(order.getTrip().getRoute().getDestinationProvince().getName())
                    .departureTime(order.getTrip().getDepartureTime())
                    .busCompanyName(order.getTrip().getBusCompany().getCompanyName())
                    .orderStatus(orderStatus)
                    .totalCost(order.getTotalCost())
                    .build();
        }).toList();
    }

    @Transactional
    public boolean unHoldSeatsByCustomer(String orderId) {
        Jwt jwt = JwtHelper.getJwt();
        Customer customer = customerRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));

        String holdInfoKey = getCustomerHoldInfoKey(customer.getId());
        String holdInfo = redisTemplate.opsForValue().get(holdInfoKey);
        if (holdInfo == null) throw new MyAppException(ErrorCode.NOT_EXISTED);

        String[] parts = holdInfo.split(":");
        if (parts.length != 3) throw new MyAppException(ErrorCode.INVALID_FORMAT);

        String redisCustomerId = parts[0];
        String redisOrderId = parts[1];
        List<String> tripSeatIdList = List.of(parts[2].split(","));

        if (!customer.getId().equals(redisCustomerId) || !orderId.equals(redisOrderId))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);

        bookingOrderRepository.findById(orderId).ifPresent(bookingOrder -> {
            List<Ticket> orderTickets = ticketRepository.findAllByBookingOrderIds(List.of(orderId));
            if (!orderTickets.isEmpty()) {
                List<String> ticketIds = orderTickets.stream().map(Ticket::getId).toList();
                List<String> cancellableStatus = List.of(TicketStatusEnum.HOLDING.name(), TicketStatusEnum.PAID.name());
                ticketRepository.updateStatusByIds(ticketIds, TicketStatusEnum.CANCELLED.name(), cancellableStatus, LocalDateTime.now());

                List<String> tripSeatIds = orderTickets.stream().map(t -> t.getTripSeat().getId()).distinct().toList();
                List<String> releasableStatus = List.of(TripSeatEnum.HELD.name(), TripSeatEnum.BOOKED.name());
                tripSeatRepository.updateStatusByIds(tripSeatIds, TripSeatEnum.AVAILABLE.name(), releasableStatus);
            }
        });

        seatReservationService.deleteInvalidOrder(customer.getId(), orderId, tripSeatIdList);
        redisTemplate.delete(holdInfoKey);
        return true;
    }

    private String getCustomerHoldInfoKey(String customerId){
        return CUSTOMER_HOLD_INFO_PREFIX + customerId;
    }
}
