package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.CancelTicketRequest;
import com.example.BusTicket.dto.request.MomoRefundRequest;
import com.example.BusTicket.dto.request.PaymentRequest;
import com.example.BusTicket.entity.*;
import com.example.BusTicket.enums.MomoEnum;
import com.example.BusTicket.enums.PaymentEnum;
import com.example.BusTicket.enums.TicketStatusEnum;
import com.example.BusTicket.enums.TripSeatEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.BookingOrderMapper;
import com.example.BusTicket.repository.jpa.*;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CancelForOrderService {
    private final BookingOrderRepository bookingOrderRepository;
    private final SeatReservationService seatReservationService;
    private final CustomerRepository customerRepository;
    private final TripSeatRepository tripSeatRepository;
    private final TripRepository tripRepository;
    private final CompanyUserRepository companyUserRepository;
    private final TicketRepository ticketRepository;
    private final BookingOrderMapper orderMapper;
    private final HistoryBookingRepository historyBookingRepository;
    private final HistoryDetailRepository historyDetailRepository;
    private final PaymentRepository paymentRepository;
    private final MomoService momoService;
    private final PaymentService paymentService;


    @Value("${booking.holdingSeatTime}")
    private int holdingSeatTime;


    @Transactional
    public boolean cancelTicketByCompany(CancelTicketRequest request, String tripId){
        Jwt jwt = JwtHelper.getJwt();
        List<String> ticketIdList = request.getTicketIdList().stream().distinct().toList();
        List<Ticket> ticketList = ticketRepository.findAllById(ticketIdList);
        if(ticketList.size() != ticketIdList.size()) throw new MyAppException(ErrorCode.TICKET_INVALID);
        List<TripSeat> tripSeatList = tripSeatRepository.getTripSeatsForCancel(ticketIdList);
        if(tripSeatList.size() != ticketIdList.size())
            throw new MyAppException(ErrorCode.TICKET_INVALID);

        List<BookingOrder> bookingOrderList = ticketList.stream().map(Ticket::getBookingOrder).distinct().toList();
        if(bookingOrderList.size() != 1) throw new MyAppException(ErrorCode.CANCEL_MULTI_ORDER);
        BookingOrder bookingOrder = bookingOrderList.getFirst();
        String bookingOrderId = bookingOrder.getId();

        List<String> tripSeatIdList = tripSeatList.stream().map(TripSeat::getId).toList();
        List<Trip> tripList = tripRepository.getTripForCancelTicket(tripSeatIdList);
        Trip trip = tripRepository.findById(tripId).orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        if(tripList.size() != 1 || !tripList.getFirst().getId().equals(tripId))
            throw new MyAppException(ErrorCode.TRIP_SEAT_INVALID);
        CompanyUser companyUser = checkCompanyPermission(jwt.getSubject(), trip);

        // update status ticket to  cancelled
        int rowUpdTicket = ticketRepository.updateStatusByIds(ticketIdList, TicketStatusEnum.CANCELLED.name()
                , TicketStatusEnum.PAID.name(), LocalDateTime.now());
        if(rowUpdTicket != ticketIdList.size()) throw new MyAppException(ErrorCode.ERROR_SAVED);
        // update status tripSeat to  available
        int rowUpdTripSeat = tripSeatRepository.updateStatusByIds(tripSeatIdList, TripSeatEnum.AVAILABLE.name(), TripSeatEnum.BOOKED.name());
        if(rowUpdTripSeat != tripSeatIdList.size()) throw new MyAppException(ErrorCode.ERROR_SAVED);

        Payment payment = paymentRepository.findByBookingOrderIdAndType(bookingOrderId, MomoEnum.PAYMENT.name());
        if(payment == null) throw new MyAppException(ErrorCode.NOT_EXISTED);
        // nếu đã thanh toán thì refund
        if(payment.getStatus().equals(PaymentEnum.SUCCESSFUL.name())){
            Long amount = ticketList.stream().mapToLong(Ticket::getPrice).sum();
            Long parentTransId = payment.getTransId();
            String description = "Hoàn trả tiền vé hủy cho đơn hàng #" + bookingOrderId;

            boolean refundResult = paymentService.refundPayment(parentTransId, bookingOrderId, amount, description);
            if(!refundResult) throw new MyAppException(ErrorCode.ERROR_MOMO_REFUND);
        }

        // chưa lưu lịch sử
        return true;
    }

    private CompanyUser checkCompanyPermission(String companyUserId, Trip trip){
        CompanyUser companyUser = companyUserRepository.findById(companyUserId)
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        if( !companyUser.getBusCompany().getId().equals(trip.getBusCompany().getId()))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);
        return companyUser;
    }

}
