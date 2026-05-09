package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.general.BusDiagram;
import com.example.BusTicket.dto.request.TripCrRequest;
import com.example.BusTicket.dto.request.TripUpRequest;
import com.example.BusTicket.dto.response.TicketResponse;
import com.example.BusTicket.dto.response.TripResponse;
import com.example.BusTicket.dto.response.TripSeatResponse;
import com.example.BusTicket.dto.response.TripSimpleResponse;
import com.example.BusTicket.entity.*;
import com.example.BusTicket.enums.TripSeatEnum;
import com.example.BusTicket.enums.TripStatusEnum;
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
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.redis.core.RedisTemplate;
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
    public TripResponse getTripById(String tripId){
        Jwt jwt = JwtHelper.getJwt();
        CompanyUser companyUser = companyUserRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = companyUser.getBusCompany();
        Trip trip = tripRepository.findById(tripId).orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        if( !busCompany.getId().equals(trip.getBusCompany().getId()))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);

        TripResponse tripResponse = tripMapper.toTripResponse(trip);

        // đếm số lượng ghế đang giữ và đã đặt (thanh toán)
        Object[] result = tripSeatRepository.countHeldAndBooked(trip.getId());
        Object[] firstRow = (Object[]) result[0];
        Long heldSeats = firstRow[0] == null ? 0 : ((Number) firstRow[0]).longValue();
        Long bookedSeats = firstRow[1] == null ? 0 : ((Number) firstRow[1]).longValue();


        // load lịch sử đặt vé(toàn bộ danh sách vé)
        List<Ticket> ticketList = ticketRepository.findAllByTripId(trip.getId());
        List<TicketResponse> historyBooking = ticketList.stream().map(ticketMapper::toTicketResponse).toList();
        tripResponse.setHistoryBooking(historyBooking);

        // load trạng thái ghế và vé đang giữ ghế
        List<Object[]> tripSeatList = tripSeatRepository.findSeatsWithLatestTicket(trip.getId());
        List<String> tripSeatIds = new ArrayList<>();
        for (Object[] obj : tripSeatList) {
            if (obj[0] != null) {
                TripSeat ts = (TripSeat) obj[0];
                if (ts.getId() != null && ts.getStatus().equals(TripSeatEnum.AVAILABLE.name()) ){
                    tripSeatIds.add(ts.getId());
                }
            }
        }
        // load ghế đang giữ trong redis
        Map<String, Boolean> heldSeatInRedisMap = checkHeldSeatsInRedis(tripSeatIds);

        List<TripSeatResponse> seatMap = new ArrayList<>();
        for(var object :tripSeatList){
            TripSeat ts = object[0] != null ? (TripSeat)object[0] : null;
            Ticket tk = object[1] != null ? (Ticket)object[1] : null;
            // check ghế đang bị giữ trong redis
            if(ts != null && ts.getStatus().equals(TripSeatEnum.AVAILABLE.name())){
                if(Boolean.TRUE.equals(heldSeatInRedisMap.get(ts.getId())) ){
                    ts.setStatus(TripSeatEnum.HELD.name());
                    heldSeats++;
                }
            }

            // lưu thông tin vé hiện tại cho ghế.
            TripSeatResponse tripSeatResponse = tripSeatMapper.toTripSeatResponse(ts);
            tripSeatResponse.setTicket(ticketMapper.toTicketResponse(tk));
            seatMap.add(tripSeatResponse);
        }
        tripResponse.setHeldSeats(heldSeats);

        tripResponse.setBookedSeats(bookedSeats);
        tripResponse.setSeatMap(seatMap);
        return tripResponse;
    }
    private Map<String, Boolean> checkHeldSeatsInRedis(List<String> tripSeatIds) {
        List<String> keys = tripSeatIds.stream()
                .map(id -> holdingSeatPrefixKey + id).toList();

        List<String> values = redisTemplate.opsForValue().multiGet(keys);

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
        trip.setStatus(TripStatusEnum.CANCELLED.name());

        // hủy các ticket

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

    
}
