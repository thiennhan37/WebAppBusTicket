package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.general.BusDiagram;
import com.example.BusTicket.dto.request.CancelTicketRequest;
import com.example.BusTicket.dto.request.TripCrRequest;
import com.example.BusTicket.dto.request.TripUpRequest;
import com.example.BusTicket.dto.response.*;
import com.example.BusTicket.entity.*;
import com.example.BusTicket.enums.*;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.TicketMapper;
import com.example.BusTicket.mapper.TripMapper;
import com.example.BusTicket.mapper.TripSeatMapper;
import com.example.BusTicket.repository.jpa.*;
import com.example.BusTicket.specification.TripSpecification;
import com.example.BusTicket.util.IdUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cglib.core.Local;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class TripService {
    private final TicketMapper ticketMapper;
    private final TicketRepository ticketRepository;
    private final TripRepository tripRepository;
    private final CompanyUserRepository companyUserRepository;
    private final RouteRepository routeRepository;
    private final BusTypeRepository busTypeRepository;
    private final TripSeatRepository tripSeatRepository;
    private final TripMapper tripMapper;
    private final TripSeatMapper tripSeatMapper;
    private final RedisTemplate<String, String> redisTemplate;
    private final CancelForOrderService cancelForOrderService;
    private final PaymentService paymentService;
    private final PaymentRepository paymentRepository;


    @Value("${booking.holdingSeatPrefixKey}")
    private String holdingSeatPrefixKey;



    @Transactional
    public TripResponse createTrip(TripCrRequest request){
        Jwt jwt = JwtHelper.getJwt();
        CompanyUser companyUser = companyUserRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = companyUser.getBusCompany();
        if( !busCompany.getId().equals(request.getBusCompanyId()))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);
        if( request.getLicensePlate() != null && !request.getLicensePlate().isBlank() &&
        tripRepository.existsByLicensePlateAndDepartureTime(request.getLicensePlate(), request.getDepartureTime()))
            throw new MyAppException(ErrorCode.BUS_BUSY);
        if(request.getDepartureTime().isBefore(LocalDateTime.now()))
            throw new MyAppException(ErrorCode.DEPARTURE_TIME_INVALID);
        Trip trip = Trip.builder()
                .id(IdUtil.generateID())
                .busCompany(busCompany)
                .busType(busTypeRepository.getReferenceById(request.getBusTypeId()))
                .route(routeRepository.getReferenceById(request.getRouteId()))
                .licensePlate(request.getLicensePlate())
                .driver(request.getDriver())
                .status(TripStatusEnum.SCHEDULED.name())
                .departureTime(request.getDepartureTime())
                .price(request.getPrice())
                .build();
        try{
            tripRepository.save(trip);
        } catch (Exception e){
            throw new MyAppException(ErrorCode.NOT_EXISTED);
        }
        return tripMapper.toTripResponse(trip);
    }
    @Transactional
    public TripResponse getTripById(String tripId){
        Jwt jwt = JwtHelper.getJwt();
        CompanyUser companyUser = companyUserRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = companyUser.getBusCompany();
        Trip trip = tripRepository.findById(tripId).orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        if(trip.getDepartureTime().isBefore(LocalDateTime.now())){
            trip.setStatus(TripStatusEnum.CLOSED.name());
            tripRepository.save(trip);
        }
        if( !busCompany.getId().equals(trip.getBusCompany().getId()))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);

        TripResponse tripResponse = tripMapper.toTripResponse(trip);

        Object[] result = tripSeatRepository.countHeldAndBooked(trip.getId());
        Object[] firstRow = (Object[]) result[0];
        long heldSeats = firstRow[0] == null ? 0 : ((Number) firstRow[0]).longValue();
        long bookedSeats = firstRow[1] == null ? 0 : ((Number) firstRow[1]).longValue();

        List<TripSeat> tripSeats = tripSeatRepository.findAllByTripId(trip.getId());
        Map<String, Ticket> ticketBySeatId = ticketRepository
                .findLatestActiveTicketsByTripIdWithDetails(trip.getId())
                .stream()
                .collect(Collectors.toMap(t -> t.getTripSeat().getId(), t -> t, (a, b) -> a));

        List<String> availableSeatIds = tripSeats.stream()
                .filter(ts -> TripSeatEnum.AVAILABLE.name().equals(ts.getStatus()))
                .map(TripSeat::getId)
                .toList();
        Map<String, Boolean> heldSeatInRedisMap = checkHeldSeatsInRedis(availableSeatIds);

        List<TripSeatResponse> seatMap = new ArrayList<>(tripSeats.size());
        for (TripSeat ts : tripSeats) {
            if (TripSeatEnum.AVAILABLE.name().equals(ts.getStatus())
                    && Boolean.TRUE.equals(heldSeatInRedisMap.get(ts.getId()))) {
                ts.setStatus(TripSeatEnum.HELD.name());
                heldSeats++;
            }
            TripSeatResponse tripSeatResponse = tripSeatMapper.toTripSeatResponse(ts);
            Ticket ticket = ticketBySeatId.get(ts.getId());
            if (ticket != null) {
                tripSeatResponse.setTicket(ticketMapper.toTicketResponse(ticket));
            }
            seatMap.add(tripSeatResponse);
        }

        tripResponse.setHeldSeats(heldSeats);
        tripResponse.setBookedSeats(bookedSeats);
        tripResponse.setSeatMap(seatMap);
        return tripResponse;
    }

    private Map<String, Boolean> checkHeldSeatsInRedis(List<String> tripSeatIds) {
        if (tripSeatIds.isEmpty()) {
            return Collections.emptyMap();
        }
        List<String> keys = tripSeatIds.stream()
                .map(id -> holdingSeatPrefixKey + id).toList();

        List<String> values = redisTemplate.opsForValue().multiGet(keys);
        if (values == null) {
            return Collections.emptyMap();
        }

        Map<String, Boolean> result = new HashMap<>();
        for (int i = 0; i < tripSeatIds.size(); i++) {
            result.put(tripSeatIds.get(i), values.get(i) != null);
        }
        return result;
    }

    public TripResponse updateTrip(String tripId, TripUpRequest request){
        Jwt jwt = JwtHelper.getJwt();
        CompanyUser companyUser = companyUserRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = companyUser.getBusCompany();
        Trip trip = tripRepository.findById(tripId).orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        if( !busCompany.getId().equals(trip.getBusCompany().getId()))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);
        if(request.getDriver() != null) trip.setDriver(request.getDriver());
        if(request.getLicensePlate() != null) trip.setLicensePlate(request.getLicensePlate());

        if(trip.getStatus().equals(TripStatusEnum.SCHEDULED.name())){
            if(request.getBusTypeId() != null) trip.setBusType(busTypeRepository.getReferenceById(request.getBusTypeId()));
            if(request.getRouteId() != null) trip.setRoute(routeRepository.getReferenceById(request.getRouteId()));
            if(request.getPrice() != null) trip.setPrice(request.getPrice());
            if(request.getDepartureTime() != null){
                if(request.getDepartureTime().isBefore(LocalDateTime.now()))
                    throw new MyAppException(ErrorCode.DEPARTURE_TIME_INVALID);
                trip.setDepartureTime(request.getDepartureTime());
            }
        }
        try{
            return tripMapper.toTripResponse(tripRepository.save(trip));
        } catch(Exception e){
            throw new MyAppException(ErrorCode.NOT_EXISTED);
        }

    }

    @Transactional
    public TripResponse openTrip(String tripId){
        Jwt jwt = JwtHelper.getJwt();
        CompanyUser companyUser = companyUserRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = companyUser.getBusCompany();
        Trip trip = tripRepository.findById(tripId).orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));

        if( !busCompany.getId().equals(trip.getBusCompany().getId()))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);
        if( !trip.getStatus().equals(TripStatusEnum.SCHEDULED.name()))
            throw new MyAppException(ErrorCode.INVALID_STATE);
        if(trip.getPrice() == null || trip.getBusType() == null || trip.getRoute() == null || trip.getDepartureTime() == null)
            throw new MyAppException(ErrorCode.MISSING_REQUIRED_FIELD);
        if(trip.getDepartureTime().isBefore(LocalDateTime.now().plusHours(1)))
            throw new MyAppException(ErrorCode.INVALID_DEPARTURE_TIME);
        trip.setStatus(TripStatusEnum.OPEN.name());

        // Lưu tripSeat cho các chuyến đã OPEN (mở bán)
        BusDiagram busDiagram = trip.getBusType().getDiagram();
        if(busDiagram == null) throw new MyAppException(ErrorCode.NOT_EXISTED);
        List<List<List<String>>> seatList = busDiagram.getSeatList();
        List<TripSeat> tripSeatList = new ArrayList<>();
        for(var floor : seatList){
            for(var row : floor){
                for(var seat : row){
                    if(seat != null && !seat.isBlank()){
                        TripSeat tripSeat = TripSeat.builder().id(IdUtil.generateID()).trip(trip).seat(seat)
                                .price(trip.getPrice()).status(TripSeatEnum.AVAILABLE.name()).build();
                        tripSeatList.add(tripSeat);
                    }
                }
            }
        }
        tripSeatRepository.saveAll(tripSeatList);
        return tripMapper.toTripResponse(tripRepository.save(trip));
    }

    @Transactional
    public void cancelTrip(String tripId){
        Jwt jwt = JwtHelper.getJwt();
        CompanyUser companyUser = companyUserRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = companyUser.getBusCompany();
        Trip trip = tripRepository.findById(tripId).orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        if( !busCompany.getId().equals(trip.getBusCompany().getId()))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);
        if( !trip.getStatus().equals(TripStatusEnum.OPEN.name()))
            throw new MyAppException(ErrorCode.CANCEL_TRIP_INVALID);
        if( trip.getDepartureTime().isBefore(LocalDateTime.now()))
            throw new MyAppException(ErrorCode.TRIP_HAS_ARRIVED);

        // hủy các ticket
        List<Ticket> ticketList = tripRepository.getTicketForCancelTrip(tripId);
        Map<String, List<Ticket>> bookingTicketMap = new HashMap<>();
        for(Ticket ticket : ticketList){
            if(ticket.getStatus().equals(TicketStatusEnum.PAID.name())){
                BookingOrder bookingOrder = ticket.getBookingOrder();
                bookingTicketMap
                        .computeIfAbsent(bookingOrder.getId(), k -> new ArrayList<>())
                        .add(ticket);
            }
        }
        for(String bookingOrderId : bookingTicketMap.keySet()){
            List<Ticket> tempTicketList = bookingTicketMap.get(bookingOrderId);
            refundTicketForCancelTrip(bookingOrderId, tempTicketList);
        }
        trip.setStatus(TripStatusEnum.CANCELLED.name());
        for(Ticket ticket : ticketList){
            ticket.setStatus(TicketStatusEnum.CANCELLED.name());
        }
        ticketRepository.saveAll(ticketList);
        tripRepository.save(trip);
    }
    public void refundTicketForCancelTrip(String bookingOrderId, List<Ticket> ticketList){
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
    }

    public Page<TripResponse> getAllTrips(String status, String keyword, LocalDate date, String busType, Pageable pageable){
        Jwt jwt = JwtHelper.getJwt();
        CompanyUser companyUser = companyUserRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = companyUser.getBusCompany();

        Pageable fixedPageable = PageRequest.of(pageable.getPageNumber(), 5, Sort.by("departureTime").descending());
        Specification<Trip>  spec = Specification
                .where(TripSpecification.hasBuscompanyId(busCompany.getId()))
                .and(TripSpecification.containsKeyword(keyword))
                .and(TripSpecification.hasDate(date))
                .and(TripSpecification.hasStatus(status))
                .and(TripSpecification.hasBusType(busType));

        return tripRepository.findAll(spec, fixedPageable).map(tripMapper::toTripResponse);
    }
    public List<TripSimpleResponse> getSimpleTripList(String arrivalProvince, String destinationProvince, LocalDate date){
        Jwt jwt = JwtHelper.getJwt();
        CompanyUser companyUser = companyUserRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = companyUser.getBusCompany();

        Sort sort = Sort.by("departureTime").ascending();
        Specification<Trip>  spec = Specification
                .where(TripSpecification.hasBuscompanyId(busCompany.getId()))
                .and(TripSpecification.hasArrivalProvince(arrivalProvince))
                .and(TripSpecification.hasDestinationProvince(destinationProvince))
                .and(TripSpecification.hasDate(date))
                .and(TripSpecification.hasStatus(TripStatusEnum.OPEN.name())
                        .or(TripSpecification.hasStatus(TripStatusEnum.CANCELLED.name()))
                        .or(TripSpecification.hasStatus(TripStatusEnum.CLOSED.name()))
                );

        List<Trip> tripList = tripRepository.findAll(spec, sort);
        List<TripSimpleResponse> tripSimpleResponseList = tripList.stream().map(tripMapper::toTripSimpleResponse).toList();
        List<String> tripIds = tripList.stream().map(Trip::getId).toList();
        List<Object[]> results = tripSeatRepository.countBookedSeats(tripIds);
        Map<String, Long> countMap = results.stream()
                .collect(Collectors.toMap(
                        row -> (String) row[0],
                        row -> row[1] == null ? 0L : ((Number) row[1]).longValue()
                ));
        for (TripSimpleResponse x : tripSimpleResponseList) {
            x.setBookedSeats(countMap.getOrDefault(x.getId(), 0L));
        }
        return tripSimpleResponseList;
    }

    @Scheduled(cron = "0 0 8 * * *")
    public void updateClosedTrip(){
        System.out.println("update closed trip");
        LocalDateTime now = LocalDateTime.now();
        List<Trip> tripList = tripRepository.getClosedTripForUpdate(now);
        for(Trip t : tripList) t.setStatus(TripStatusEnum.CLOSED.name());
        tripRepository.saveAll(tripList);
    }
}
