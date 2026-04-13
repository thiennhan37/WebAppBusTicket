package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.TripCrRequest;
import com.example.BusTicket.dto.request.TripUpRequest;
import com.example.BusTicket.dto.response.TripResponse;
import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.CompanyUser;
import com.example.BusTicket.entity.Trip;
import com.example.BusTicket.enums.TripStatusEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.TripMapper;
import com.example.BusTicket.repository.jpa.*;
import com.example.BusTicket.specification.TripSpecification;
import com.example.BusTicket.util.IdUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
public class TripService {
    private final TripRepository tripRepository;
    private final CompanyUserRepository companyUserRepository;
    private final BusCompanyRepository busCompanyRepository;
    private final RouteRepository routeRepository;
    private final BusTypeRepository busTypeRepository;
    private final TripMapper tripMapper;


    public TripResponse createTrip(TripCrRequest request){
        Jwt jwt = JwtHelper.getJwt();
        CompanyUser companyUser = companyUserRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = companyUser.getBusCompany();
//        if( !busCompany.getId().equals(request.getBusCompanyId()))
//            throw new MyAppException(ErrorCode.ACCESS_DENIED);
        if(tripRepository.existsByLicensePlateAndDepartureTime(request.getLicensePlate(), request.getDepartureTime()))
            throw new MyAppException(ErrorCode.BUS_BUSY);

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
            return tripMapper.toTripResponse(trip);
        } catch (Exception e){
            throw new MyAppException(ErrorCode.NOT_EXISTED);
        }
    }
    public TripResponse getTrip(String tripId){
        Jwt jwt = JwtHelper.getJwt();
        CompanyUser companyUser = companyUserRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = companyUser.getBusCompany();
        Trip trip = tripRepository.findById(tripId).orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        if( !busCompany.getId().equals(trip.getBusCompany().getId()))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);
        return tripMapper.toTripResponse(trip);
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
        if(request.getPrice() != null) trip.setPrice(request.getPrice());
        if(trip.getStatus().equals(TripStatusEnum.SCHEDULED.name())){
            if(request.getBusTypeId() != null) trip.setBusType(busTypeRepository.getReferenceById(request.getBusTypeId()));
            if(request.getRouteId() != null) trip.setRoute(routeRepository.getReferenceById(request.getRouteId()));
            if(request.getDepartureTime() != null) trip.setDepartureTime(request.getDepartureTime());
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
        return tripMapper.toTripResponse(tripRepository.save(trip));
    }
    public Boolean cancelTrip(String tripId){
        Jwt jwt = JwtHelper.getJwt();
        CompanyUser companyUser = companyUserRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = companyUser.getBusCompany();
        Trip trip = tripRepository.findById(tripId).orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        if( !busCompany.getId().equals(trip.getBusCompany().getId()))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);
        if(trip.getStatus().equals(TripStatusEnum.OPEN.name())) trip.setStatus(TripStatusEnum.CANCELLED.name());
        // hủy các ticket
        return true;
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
    
}
