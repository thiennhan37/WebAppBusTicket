package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.TripRatingRequest;
import com.example.BusTicket.dto.response.BusCompanyRatingResponse;
import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.entity.Customer;
import com.example.BusTicket.entity.Ticket;
import com.example.BusTicket.entity.TripRating;
import com.example.BusTicket.enums.TicketStatusEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.repository.jpa.BookingOrderRepository;
import com.example.BusTicket.repository.jpa.CustomerRepository;
import com.example.BusTicket.repository.jpa.TicketRepository;
import com.example.BusTicket.repository.jpa.TripRatingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class TripRatingService {
    private final BookingOrderRepository bookingOrderRepository;
    private final CustomerRepository customerRepository;
    private final TicketRepository ticketRepository;
    private final TripRatingRepository tripRatingRepository;

    @Transactional
    public void rateTrip(String orderId, TripRatingRequest request) {
        Jwt jwt = JwtHelper.getJwt();
        Customer customer = customerRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));

        BookingOrder bookingOrder = bookingOrderRepository.findById(orderId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));

        if (!bookingOrder.getBookingUser().getId().equals(customer.getId())) {
            throw new MyAppException(ErrorCode.ACCESS_DENIED);
        }

        List<Ticket> tickets = ticketRepository.findAllByBookingOrderId(orderId);
        boolean hasPaidTicket = tickets.stream()
                .anyMatch(t -> TicketStatusEnum.PAID.name().equalsIgnoreCase(t.getStatus()));
        if (!hasPaidTicket) {
            throw new MyAppException(ErrorCode.ACCESS_DENIED);
        }

        if (tripRatingRepository.existsByBookingOrderId(orderId)) {
            throw new MyAppException(ErrorCode.RATED_ORDER);
        }

        double avgScore = (request.getServiceQuality() + request.getPunctuality() + request.getSafety() + request.getCleanliness()) / 4.0;

        TripRating tripRating = TripRating.builder()
                .serviceQuality(request.getServiceQuality())
                .punctuality(request.getPunctuality())
                .safety(request.getSafety())
                .cleanliness(request.getCleanliness())
                .averageStars(avgScore)
                .createdAt(LocalDateTime.now())
                .description(request.getDescription())
                .bookingOrder(bookingOrder)
                .customer(customer)
                .busCompany(bookingOrder.getTrip().getBusCompany())
                .build();
        tripRatingRepository.save(tripRating);
    }

    public BusCompanyRatingResponse getCompanyRating(String companyId) {
        List<Object[]> rows = tripRatingRepository.getCompanyRatingSummary(companyId);
        Object[] summary = rows.isEmpty() ? new Object[]{0.0, 0L} : rows.getFirst();
        double avg = summary[0] == null ? 0.0 : ((Number) summary[0]).doubleValue();
        int count = (int)(summary[1] == null ? 0L : ((Number) summary[1]).intValue());

        return BusCompanyRatingResponse.builder()
                .companyId(companyId)
                .avgStars(Math.round(avg * 100.0) / 100.0)
                .totalRatings(count)
                .build();
    }
}