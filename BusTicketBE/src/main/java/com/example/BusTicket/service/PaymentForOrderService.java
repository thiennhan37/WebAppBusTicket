package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.BookingOrderCrRequest;
import com.example.BusTicket.dto.request.BookingOrderDelRequest;
import com.example.BusTicket.dto.request.CompHoldSeatRequest;
import com.example.BusTicket.dto.response.BookingOrderResponse;
import com.example.BusTicket.entity.*;
import com.example.BusTicket.enums.HistoryStatusEnum;
import com.example.BusTicket.enums.TicketStatusEnum;
import com.example.BusTicket.enums.TripSeatEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.BookingOrderMapper;
import com.example.BusTicket.repository.jpa.*;
import com.example.BusTicket.util.IdUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class PaymentForOrderService {
    private final BookingOrderRepository bookingOrderRepository;
    private final SeatReservationService seatReservationService;
    private final CustomerRepository customerRepository;
    private final TripSeatRepository tripSeatRepository;
    private final TripRepository tripRepository;
    private final CompanyUserRepository companyUserRepository;
    private final RouteStopRepository routeStopRepository;
    private final TicketRepository ticketRepository;
    private final BookingOrderMapper orderMapper;
    private final HistoryBookingRepository historyBookingRepository;
    private final HistoryDetailRepository historyDetailRepository;


    @Value("${booking.holdingSeatTime}")
    private int holdingSeatTime;

    @Transactional
    public String payForOrderSuccessfully(CompHoldSeatRequest request, String tripId){
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
