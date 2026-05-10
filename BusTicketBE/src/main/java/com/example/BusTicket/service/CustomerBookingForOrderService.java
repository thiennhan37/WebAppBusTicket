package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.BookingOrderCrRequest;
import com.example.BusTicket.dto.request.CompHoldSeatRequest;
import com.example.BusTicket.dto.request.MomoPaymentRequest;
import com.example.BusTicket.dto.request.PaymentRequest;
import com.example.BusTicket.dto.response.BookingOrderResponse;
import com.example.BusTicket.dto.response.MomoPaymentResponse;
import com.example.BusTicket.entity.*;
import com.example.BusTicket.enums.*;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.BookingOrderMapper;
import com.example.BusTicket.repository.jpa.*;
import com.example.BusTicket.util.IdUtil;
import lombok.RequiredArgsConstructor;
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

@Service
@RequiredArgsConstructor
public class CustomerBookingForOrderService {
    private final BookingOrderRepository bookingOrderRepository;
    private final SeatReservationService seatReservationService;
    private final CustomerRepository customerRepository;
    private final TripSeatRepository tripSeatRepository;
    private final TripRepository tripRepository;
    private final RouteStopRepository routeStopRepository;
    private final TicketRepository ticketRepository;
    private final BookingOrderMapper orderMapper;
    private final HistoryBookingRepository historyBookingRepository;
    private final HistoryDetailRepository historyDetailRepository;
    private final SendMailService sendMailService;
    private final PaymentService paymentService;
    private final MomoService momoService;
    private final RedisTemplate<String, String> redisTemplate;

    @Value("${booking.holdingSeatTime}")
    private int holdingSeatTime;
    @Value("${booking.paymentExpirationTime}")
    private int paymentExpirationTime;
    @Value("${booking.paymentPrefixKey}")
    private String paymentPrefixKey;
    @Value("${booking.customerHoldingSeatPrefixKey}")
    private String CUSTOMER_HOLD_INFO_PREFIX;

    @Transactional
    public String holdSeatsByCustomer(CompHoldSeatRequest request, String tripId){
        Jwt jwt = JwtHelper.getJwt();
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        if( !trip.getStatus().equals(TripStatusEnum.OPEN.name()))
            throw new MyAppException(ErrorCode.TRIP_NOT_OPEN);

        Customer customer = customerRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));

        String holdInfoKey = getCustomerHoldInfoKey(customer.getId());
        if(Boolean.TRUE.equals(redisTemplate.hasKey(holdInfoKey)))
            throw new MyAppException(ErrorCode.BOOKING_ANOTHER_ORDER);

        List<String> tripSeatIdList = request.getTripSeatIdList().stream().distinct().toList();
        if(tripSeatIdList.isEmpty()) throw new MyAppException(ErrorCode.INVALID_PARAMETER);

        String orderId = IdUtil.generateID();
        boolean isHoldSeats = seatReservationService
                .tryHoldSeats(null, customer.getId(), orderId, tripSeatIdList, holdingSeatTime);
        if( !isHoldSeats) throw new MyAppException(ErrorCode.ERROR_SAVED);

        List<TripSeat> tripSeatList = tripSeatRepository.getValidTripSeatList(tripSeatIdList, trip.getId());
        if(tripSeatIdList.size() != tripSeatList.size()){
            seatReservationService.deleteInvalidOrder(customer.getId(), orderId, tripSeatIdList);
            throw new MyAppException(ErrorCode.TRIP_SEAT_BOOKED);
        }

        String holdInfo = customer.getId() + ":" + orderId + ":" + String.join(",", tripSeatIdList);
        redisTemplate.opsForValue().set(holdInfoKey, holdInfo, Duration.ofSeconds(holdingSeatTime));
        return orderId;
    }


    private String getCustomerHoldInfoKey(String customerId){
        return CUSTOMER_HOLD_INFO_PREFIX + customerId;
    }

    @Transactional
    public BookingOrderResponse bookOrderByCustomer(BookingOrderCrRequest request, String tripId){
        Jwt jwt = JwtHelper.getJwt();
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        if( !trip.getStatus().equals(TripStatusEnum.OPEN.name()))
            throw new MyAppException(ErrorCode.TRIP_NOT_OPEN);

        Customer customer = customerRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));

        RouteStop arrival = routeStopRepository.findById(request.getArrivalId())
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        RouteStop destination = routeStopRepository.findById(request.getDestinationId())
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        checkRouteStop(arrival, destination, trip);

        List<String> tripSeatIdList = request.getTripSeatIdList().stream().distinct().toList();
        if(tripSeatIdList.isEmpty()) throw new MyAppException(ErrorCode.INVALID_PARAMETER);


        String orderId = request.getId();
        seatReservationService.checkValidOrder(orderId, tripSeatIdList);
        List<TripSeat> tripSeatList = tripSeatRepository.getValidTripSeatList(tripSeatIdList, trip.getId());
        if(tripSeatIdList.size() != tripSeatList.size()) throw new MyAppException(ErrorCode.TRIP_SEAT_BOOKED);

        Long totalCost = tripSeatList.stream()
                .mapToLong(tripSeat -> tripSeat.getPrice() != null ? tripSeat.getPrice() : 0).sum();
        BookingOrder bookingOrder = BookingOrder.builder()
                .id(orderId)
                .trip(trip)
                .bookingUser(customer)
                .createdAt(LocalDateTime.now())
                .creatingStaff(null)
                .customerEmail(customer.getEmail())
                .customerName(customer.getFullName())
                .customerPhone(customer.getPhone())
                .totalCost(totalCost)
                .build();

        bookingOrderRepository.save(bookingOrder);
        tripSeatRepository.updateStatusByIds(tripSeatIdList, TripSeatEnum.HELD.name(), List.of(TripSeatEnum.AVAILABLE.name()));
        List<Ticket> ticketList = saveTicketList(tripSeatList, bookingOrder, arrival, destination);
        saveHistoryForBooking(bookingOrder, customer, ticketList);
        Payment payment = savePaymentIntoRedis(bookingOrder);
        seatReservationService.deleteInvalidOrder(customer.getId(), orderId, tripSeatIdList);
        sendMailService.sendBookingPaymentEmail(bookingOrder, payment);
        return orderMapper.toBookingOrderResponse(bookingOrder);
    }

    private Payment savePaymentIntoRedis(BookingOrder bookingOrder){
        PaymentRequest request = PaymentRequest.builder().amount(bookingOrder.getTotalCost())
                .bookingOrderId(bookingOrder.getId()).type(MomoEnum.PAYMENT.name()).build();
        Payment payment = paymentService.createPayment(request);
        MomoPaymentRequest momoPaymentRequest = MomoPaymentRequest.builder().bookingOrderId(bookingOrder.getId())
                .paymentId(payment.getId()).orderInfo("Thanh toán hóa đơn #" + bookingOrder.getId()).build();
        MomoPaymentResponse response = momoService.createMomoPayment(momoPaymentRequest);
        redisTemplate.opsForValue().set(paymentPrefixKey + payment.getId(), response.getPayUrl(), Duration.ofSeconds(paymentExpirationTime));
        return payment;
    }

    private List<Ticket> saveTicketList(List<TripSeat> tripSeatList, BookingOrder bookingOrder, RouteStop arrival, RouteStop destination){
        List<Ticket> ticketList = new ArrayList<>();
        for (TripSeat ts : tripSeatList){
            ticketList.add(Ticket.builder().id(IdUtil.generateID()).bookingOrder(bookingOrder).tripSeat(ts).price(ts.getPrice())
                    .arrival(arrival).destination(destination).status(TicketStatusEnum.HOLDING.name())
                    .updatedAt(bookingOrder.getCreatedAt()).build());
        }
        return ticketRepository.saveAll(ticketList);
    }

    private void saveHistoryForBooking(BookingOrder bookingOrder, Customer customer, List<Ticket> ticketList){
        HistoryBooking historyBooking = HistoryBooking.builder().type(HistoryStatusEnum.BOOKING.name())
                .bookingOrder(bookingOrder).actor(null).customer(customer).createdAt(LocalDateTime.now()).build();
        historyBooking = historyBookingRepository.save(historyBooking);
        List<HistoryDetail> historyDetailList = new ArrayList<>();
        for (Ticket t : ticketList){
            historyDetailList.add(HistoryDetail.builder().historyBooking(historyBooking).ticket(t).build());
        }
        historyDetailRepository.saveAll(historyDetailList);
    }
    private void checkRouteStop(RouteStop arrival, RouteStop destination, Trip trip){
        Long routeId1 = arrival.getRoute().getId();
        Long routeId2 = destination.getRoute().getId();
        Long routeId = trip.getRoute().getId();
        if(!Objects.equals(routeId, routeId1) || !Objects.equals(routeId, routeId2))
            throw new MyAppException(ErrorCode.ROUTE_STOP_INVALID);
        if( !arrival.getType().equals("UP") || !destination.getType().equals("DOWN"))
            throw new MyAppException(ErrorCode.ROUTE_STOP_INVALID);

    }
}