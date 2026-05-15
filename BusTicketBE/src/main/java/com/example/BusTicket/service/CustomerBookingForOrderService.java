package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.*;
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
    private final PaymentRepository paymentRepository;

    @Value("${booking.holdingSeatTime}")
    private int holdingSeatTime;
    @Value("${booking.paymentPrefixKey}")
    private String paymentPrefixKey;
    @Value("${booking.customerHoldingSeatPrefixKey}")
    private String CUSTOMER_HOLD_INFO_PREFIX;


    public boolean isOrderPaid(String bookingOrderId){
        Jwt jwt = JwtHelper.getJwt();
        BookingOrder bookingOrder = bookingOrderRepository.findById(bookingOrderId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));

        Customer customer = customerRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));

        if (!bookingOrder.getBookingUser().getId().equals(customer.getId()))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);

        return paymentRepository.existsByBookingOrderIdAndTypeAndStatus(
                bookingOrderId,
                MomoEnum.PAYMENT.name(),
                PaymentEnum.SUCCESSFUL.name()
        );
    }



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
//        tripSeatRepository.updateStatusByIds(tripSeatIdList, TripSeatEnum.HELD.name(), List.of(TripSeatEnum.AVAILABLE.name()));
        String holdInfo = customer.getId() + ":" + orderId + ":" + String.join(",", tripSeatIdList);
        redisTemplate.opsForValue().set(holdInfoKey, holdInfo, Duration.ofSeconds(holdingSeatTime));
        return orderId;
    }


    private String getCustomerHoldInfoKey(String customerId){
        return CUSTOMER_HOLD_INFO_PREFIX + customerId;
    }


    @Transactional
    public MomoPaymentResponse createPaymentForOrder(String orderId, CustomerPaymentRequest request) {
        // 1. Validate JWT và lấy customer hiện tại
        Jwt jwt = JwtHelper.getJwt();
        Customer customer = customerRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.UNAUTHENTICATED));
        // 2. Validate order exists trong Redis và thuộc về customer này
        String holdInfoKey = getCustomerHoldInfoKey(customer.getId());
        String holdInfo = redisTemplate.opsForValue().get(holdInfoKey);

        if (holdInfo == null) {
            throw new MyAppException(ErrorCode.NOT_EXISTED);
        }

        // Parse thông tin từ Redis: customerId:orderId:tripSeatIds
        String[] parts = holdInfo.split(":");
        if (parts.length != 3) {
            throw new MyAppException(ErrorCode.INVALID_FORMAT);
        }

        String redisCustomerId = parts[0];
        String redisOrderId = parts[1];
        String tripSeatIdsStr = parts[2];

        // Validate orderId khớp
        if (!redisOrderId.equals(orderId)) {
            throw new MyAppException(ErrorCode.NOT_EXISTED);
        }

        // Validate customer sở hữu order này
        if (!redisCustomerId.equals(customer.getId())) {
            throw new MyAppException(ErrorCode.UNAUTHORIZED);
        }

        // Parse tripSeatIds
        List<String> tripSeatIdList = List.of(tripSeatIdsStr.split(","));

        // 3. Lấy tripId từ một trong các tripSeat
        TripSeat firstTripSeat = tripSeatRepository.findById(tripSeatIdList.get(0))
                .orElseThrow(() -> new MyAppException(ErrorCode.TRIP_SEAT_INVALID));
        String tripId = firstTripSeat.getTrip().getId();

        // 4. Validate trip và seats
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        if (!trip.getStatus().equals(TripStatusEnum.OPEN.name())) {
            throw new MyAppException(ErrorCode.TRIP_NOT_OPEN);
        }

        // Validate seats vẫn available và thuộc về trip
        seatReservationService.checkValidOrder(orderId, tripSeatIdList);
        List<TripSeat> tripSeatList = tripSeatRepository.getValidTripSeatList(tripSeatIdList, trip.getId());
        if (tripSeatIdList.size() != tripSeatList.size()) {
            throw new MyAppException(ErrorCode.TRIP_SEAT_BOOKED);
        }

        // 5. Tạo booking order từ thông tin đã hold
        // Lấy arrival và destination stops (tương tự logic cũ)
        List<RouteStop> upStops = routeStopRepository.findAllByRouteIdAndType(trip.getRoute().getId(), "UP");
        List<RouteStop> downStops = routeStopRepository.findAllByRouteIdAndType(trip.getRoute().getId(), "DOWN");
        if (upStops.isEmpty() || downStops.isEmpty()) {
            throw new MyAppException(ErrorCode.ROUTE_STOP_INVALID);
        }

        RouteStop arrival = upStops.stream().min(java.util.Comparator.comparing(RouteStop::getId))
                .orElseThrow(() -> new MyAppException(ErrorCode.ROUTE_STOP_INVALID));
        RouteStop destination = downStops.stream().max(java.util.Comparator.comparing(RouteStop::getId))
                .orElseThrow(() -> new MyAppException(ErrorCode.ROUTE_STOP_INVALID));

        // Tính tổng tiền
        Long totalCost = tripSeatList.stream()
                .mapToLong(tripSeat -> tripSeat.getPrice() != null ? tripSeat.getPrice() : 0).sum();

        // Tạo booking order
        BookingOrder bookingOrder = BookingOrder.builder()
                .id(orderId)
                .trip(trip)
                .bookingUser(customer)
                .createdAt(LocalDateTime.now())
                .creatingStaff(null)
                .customerEmail(request.getCustomerEmail())
                .customerName(request.getCustomerName())
                .customerPhone(request.getCustomerPhone())
                .totalCost(totalCost)
                .build();

        bookingOrderRepository.save(bookingOrder);

        // Tạo tickets
        List<Ticket> ticketList = saveTicketList(tripSeatList, bookingOrder, arrival, destination);

        // Lưu history
        saveHistoryForBooking(bookingOrder, customer, ticketList);

        // 6. Tạo payment và MoMo QR
        PaymentRequest paymentRequest = PaymentRequest.builder()
                .amount(bookingOrder.getTotalCost())
                .bookingOrderId(bookingOrder.getId())
                .type(MomoEnum.PAYMENT.name())
                .build();

        Payment payment = paymentService.createPayment(paymentRequest);

        MomoPaymentRequest momoPaymentRequest = MomoPaymentRequest.builder()
                .bookingOrderId(bookingOrder.getId())
                .paymentId(payment.getId())
                .orderInfo("Thanh toán hóa đơn #" + bookingOrder.getId())
                .build();

        MomoPaymentResponse momoResponse = momoService.createMomoPayment(momoPaymentRequest, AccountType.CUSTOMER);

        // Lưu payment URL vào Redis
        redisTemplate.opsForValue().set(paymentPrefixKey + payment.getId(),
                momoResponse.getPayUrl(), Duration.ofSeconds(holdingSeatTime));

        // Xóa hold info từ Redis sau khi tạo payment thành công
        seatReservationService.deleteInvalidOrder(customer.getId(), orderId, tripSeatIdList);

        return momoResponse;
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
