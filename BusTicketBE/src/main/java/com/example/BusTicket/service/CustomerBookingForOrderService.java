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

        int updatedSeats = tripSeatRepository.updateStatusByIds(
                tripSeatIdList,
                TripSeatEnum.HELD.name(),
                List.of(TripSeatEnum.AVAILABLE.name())
        );
        if(updatedSeats != tripSeatIdList.size()){
            seatReservationService.deleteInvalidOrder(customer.getId(), orderId, tripSeatIdList);
            throw new MyAppException(ErrorCode.TRIP_SEAT_BOOKED);
        }

        // Tính tổng tiền tại thời điểm giữ ghế
        Long totalCost = tripSeatList.stream()
                .mapToLong(tripSeat -> tripSeat.getPrice() != null ? tripSeat.getPrice() : 0).sum();

        // Tạo booking order tạm thời (sẽ được cập nhật thông tin khách khi khách gọi createPayment)
        BookingOrder bookingOrder = BookingOrder.builder()
                .id(orderId)
                .trip(trip)
                .bookingUser(customer)
                .customerName(customer.getFullName())
                .customerPhone(customer.getPhone())
                .customerEmail(customer.getEmail())
                .createdAt(LocalDateTime.now())
                .creatingStaff(null)
                .totalCost(totalCost)
                .build();
        bookingOrderRepository.save(bookingOrder);

        // Tạo ticket với trạng thái HOLDING để đảm bảo booking flow khi payment thành công
        List<RouteStop> upStops = routeStopRepository.findAllByRouteIdAndType(trip.getRoute().getId(), "UP");
        List<RouteStop> downStops = routeStopRepository.findAllByRouteIdAndType(trip.getRoute().getId(), "DOWN");
        if (upStops.isEmpty() || downStops.isEmpty()) {
            throw new MyAppException(ErrorCode.ROUTE_STOP_INVALID);
        }

        RouteStop arrival = upStops.stream().min(java.util.Comparator.comparing(RouteStop::getId))
                .orElseThrow(() -> new MyAppException(ErrorCode.ROUTE_STOP_INVALID));
        RouteStop destination = downStops.stream().max(java.util.Comparator.comparing(RouteStop::getId))
                .orElseThrow(() -> new MyAppException(ErrorCode.ROUTE_STOP_INVALID));

        List<Ticket> ticketList = saveTicketList(tripSeatList, bookingOrder, arrival, destination);

        // Lưu lịch sử booking tạm thời
        saveHistoryForBooking(bookingOrder, customer, ticketList);

        // Tạo payment PENDING cho order này
        PaymentRequest paymentRequest = PaymentRequest.builder()
                .amount(totalCost)
                .bookingOrderId(bookingOrder.getId())
                .type(MomoEnum.PAYMENT.name())
                .build();

        Payment payment = paymentService.createPayment(paymentRequest);

        // Tạo momo payment (QR + payUrl) lưu vào redis để khách lấy QR sau
        MomoPaymentRequest momoPaymentRequest = MomoPaymentRequest.builder()
                .bookingOrderId(bookingOrder.getId())
                .paymentId(payment.getId())
                .orderInfo("Thanh toán hóa đơn #" + bookingOrder.getId())
                .build();

        MomoPaymentResponse momoResponse = momoService.createMomoPayment(momoPaymentRequest, AccountType.CUSTOMER);
        redisTemplate.opsForValue().set(paymentPrefixKey + payment.getId(),
                momoResponse.getPayUrl(), Duration.ofSeconds(holdingSeatTime));
        redisTemplate.opsForValue().set(paymentPrefixKey + payment.getId() + ":qr",
                momoResponse.getQrCodeUrl(), Duration.ofSeconds(holdingSeatTime));

        // vẫn lưu hold info cho client
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

        // 2. Load booking order và kiểm tra quyền sở hữu
        BookingOrder bookingOrder = bookingOrderRepository.findById(orderId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        if (bookingOrder.getBookingUser() == null || !bookingOrder.getBookingUser().getId().equals(customer.getId()))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);

        // 3. Cập nhật thông tin liên hệ khách (tên, phone, email)
        if (request.getCustomerName() != null && !request.getCustomerName().isBlank())
            bookingOrder.setCustomerName(request.getCustomerName());
        if (request.getCustomerPhone() != null && !request.getCustomerPhone().isBlank())
            bookingOrder.setCustomerPhone(request.getCustomerPhone());
        if (request.getCustomerEmail() != null && !request.getCustomerEmail().isBlank())
            bookingOrder.setCustomerEmail(request.getCustomerEmail());
        bookingOrderRepository.save(bookingOrder);

        // 4. Lấy payment đã tạo khi hold và trả về momo QR cho khách
        Payment payment = paymentRepository.findByBookingOrderIdAndType(orderId, MomoEnum.PAYMENT.name());
        if (payment == null) throw new MyAppException(ErrorCode.NOT_EXISTED);

        return paymentService.getMomoQrForCustomer(payment.getId());
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
