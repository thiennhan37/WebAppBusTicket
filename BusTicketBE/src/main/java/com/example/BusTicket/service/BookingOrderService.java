package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.BookingOrderCrRequest;
import com.example.BusTicket.dto.request.BookingOrderDelRequest;
import com.example.BusTicket.dto.request.CompHoldSeatRequest;
import com.example.BusTicket.dto.response.BookingOrderResponse;
import com.example.BusTicket.entity.*;
import com.example.BusTicket.enums.TicketStatusEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.OrderMapper;
import com.example.BusTicket.repository.jpa.*;
import com.example.BusTicket.util.IdUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class BookingOrderService {
    private final BookingOrderRepository bookingOrderRepository;
    private final SeatReservationService seatReservationService;
    private final CustomerRepository customerRepository;
    private final TripSeatRepository tripSeatRepository;
    private final TripRepository tripRepository;
    private final CompanyUserRepository companyUserRepository;
    private final RouteStopRepository routeStopRepository;
    private final TicketRepository ticketRepository;
    private final OrderMapper orderMapper;
    private final RedisTemplate<String, String> redisTemplate;

    @Value("${booking.holdingSeatTime}")
    private int holdingSeatTime;

    @Transactional
    public String holdSeatsByCompany(CompHoldSeatRequest request, String tripId){
        Jwt jwt = JwtHelper.getJwt();
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        // check quyền thêm order dành cho nhân viên công ty sỡ hữu chuyến đi này.
        CompanyUser creatingStaff = checkCompanyPermission(jwt.getSubject(), trip);

        List<String> tripSeatIdList = request.getTripSeatIdList().stream().distinct().toList();
        if(tripSeatIdList.isEmpty()) throw new MyAppException(ErrorCode.INVALID_PARAMETER);

        // lưu key giữ ghế trên redis bằng Lua script
        String orderId = IdUtil.generateID();
        boolean isHoldSeats = seatReservationService
                .tryHoldSeats(creatingStaff.getId(), null, orderId, tripSeatIdList, holdingSeatTime);
        if( !isHoldSeats) throw new MyAppException(ErrorCode.ERROR_SAVED);

        // kiểm tra các trip_seat trong db, nếu đã bị đặt thì hủy order trong redis
        List<TripSeat> tripSeatList = tripSeatRepository.getValidTripSeatList(tripSeatIdList, trip.getId());
        if(tripSeatIdList.size() != tripSeatList.size()){
            seatReservationService.deleteInvalidOrder(creatingStaff.getId(), orderId, tripSeatIdList);
            throw new MyAppException(ErrorCode.TRIP_SEAT_BOOKED);
        }
        return orderId;
    }
    @Transactional
    public BookingOrderResponse bookOrderByCompany(BookingOrderCrRequest request, String tripId){
        Jwt jwt = JwtHelper.getJwt();
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        // check quyền thêm order dành cho nhân viên công ty sỡ hữu chuyến đi này.
        CompanyUser creatingStaff = checkCompanyPermission(jwt.getSubject(), trip);

        RouteStop arrival = routeStopRepository.findById(request.getArrivalId())
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        RouteStop destination = routeStopRepository.findById(request.getDestinationId())
                        .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        // kiểm tra điểm đón/trả có cùng thuộc 1 tuyến đươờng?, có đúng loại đón/trả tương ứng
        checkRouteStop(arrival, destination, trip);

        List<String> tripSeatIdList = request.getTripSeatIdList().stream().distinct().toList();
        if(tripSeatIdList.isEmpty()) throw new MyAppException(ErrorCode.INVALID_PARAMETER);


        String orderId = request.getId();
        seatReservationService.checkValidOrder(orderId, tripSeatIdList);
        List<TripSeat> tripSeatList = tripSeatRepository.getValidTripSeatList(tripSeatIdList, trip.getId());
        if(tripSeatIdList.size() != tripSeatList.size()){
            seatReservationService.deleteInvalidOrder(creatingStaff.getId(), orderId, tripSeatIdList);
            throw new MyAppException(ErrorCode.TRIP_SEAT_BOOKED);
        }

        Long totalCost = tripSeatList.stream()
                .mapToLong(tripSeat -> tripSeat.getPrice() != null ? tripSeat.getPrice() : 0).sum();
        BookingOrder bookingOrder = BookingOrder.builder()
                .id(request.getId())
                .trip(trip)
                .bookingUser(null)
                .createdAt(LocalDateTime.now())
                .creatingStaff(creatingStaff)
                .customerEmail(request.getCustomerEmail())
                .customerName(request.getCustomerName())
                .customerPhone(request.getCustomerPhone())
                .totalCost(totalCost)
                .build();
        bookingOrderRepository.save(bookingOrder);
        saveTicketList(tripSeatList, bookingOrder, arrival, destination);
        return orderMapper.toBookingOrderResponse(bookingOrder);
    }
    private void saveTicketList(List<TripSeat> tripSeatList,BookingOrder bookingOrder, RouteStop arrival, RouteStop destination){
        List<Ticket> ticketList = new ArrayList<>();
        for(TripSeat ts : tripSeatList){
            Ticket ticket = Ticket.builder()
                    .id(IdUtil.generateID())
                    .bookingOrder(bookingOrder)
                    .tripSeat(ts)
                    .price(ts.getPrice())
                    .arrival(arrival)
                    .destination(destination)
                    .status(TicketStatusEnum.HOLDING.name())
                    .build();
            ticketList.add(ticket);
        }
        ticketRepository.saveAll(ticketList);
    }

    // đã fix bug comp A xóa được trip_seat của B nếu A nhập đúng order của A và nhập các tripSeatId của order của B
    public boolean deleteInvalidOrder(BookingOrderDelRequest request, String tripId){
        Jwt jwt = JwtHelper.getJwt();
        Trip trip = tripRepository.findById(tripId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        // check quyền thêm order dành cho nhân viên công ty sỡ hữu chuyến đi này.
        CompanyUser creatingStaff = checkCompanyPermission(jwt.getSubject(), trip);
        String orderId = request.getId();
        List<String> tripSeatIdList = request.getTripSeatIdList().stream().distinct().toList();
        if(tripSeatIdList.isEmpty()) throw new MyAppException(ErrorCode.TRIP_SEAT_INVALID);
        seatReservationService.deleteInvalidOrder(creatingStaff.getId(), orderId, tripSeatIdList);
        return true;
    }
    private CompanyUser checkCompanyPermission(String companyUserId, Trip trip){
        CompanyUser companyUser = companyUserRepository.findById(companyUserId)
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        if( !companyUser.getBusCompany().getId().equals(trip.getBusCompany().getId()))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);
        return companyUser;
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
