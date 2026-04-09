package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.RouteCrRequest;
import com.example.BusTicket.dto.response.RouteResponse;
import com.example.BusTicket.dto.response.RouteStopResponse;
import com.example.BusTicket.entity.*;
import com.example.BusTicket.enums.StopType;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.RouteMapper;
import com.example.BusTicket.mapper.RouteStopMapper;
import com.example.BusTicket.repository.jpa.*;
import com.example.BusTicket.specification.RouteSpecification;
import com.example.BusTicket.specification.StopSpecification;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class RouteService {
    private final RouteStopMapper routeStopMapper;
    private final RouteRepository routeRepository;
    private final CompanyUserRepository companyUserRepository;
    private final StopRepository stopRepository;
    private final ProvinceRepository provinceRepository;
    private final RouteStopRepository routeStopRepository;
    private final RouteMapper routeMapper;


    @Transactional
    public Route createRoute(RouteCrRequest request){
        List<Long> upStopIdList = request.getUpStopIdList();
        List<Long> downStopIdList = request.getDownStopIdList();
        if(upStopIdList.isEmpty() || downStopIdList.isEmpty()) throw new MyAppException(ErrorCode.MISSING_REQUIRED_FIELD);

        Jwt jwt = JwtHelper.getJwt();
        String id = jwt.getSubject();
        CompanyUser user = companyUserRepository.findById(id)
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = user.getBusCompany();
        if( ! busCompany.getId().equals(request.getBusCompanyId())) throw new MyAppException(ErrorCode.ACCESS_DENIED);

        Province arrivalProvince = provinceRepository.getReferenceById(request.getArrivalId());
        Province destinationProvince = provinceRepository.getReferenceById(request.getDestinationId());
        Route route = Route.builder()
                .name(request.getName())
                .arrivalProvince(arrivalProvince)
                .destinationProvince(destinationProvince)
                .busCompany(busCompany)
                .build();
        route = routeRepository.save(route);

        long validUpStopCount = routeStopRepository.countValidStop(upStopIdList, arrivalProvince.getId());
        if(validUpStopCount != upStopIdList.size()) throw new MyAppException(ErrorCode.INVALID_PARAMETER);
        long validDownStopCount = routeStopRepository.countValidStop(downStopIdList, destinationProvince.getId());
        if(validDownStopCount != downStopIdList.size()) throw new MyAppException(ErrorCode.INVALID_PARAMETER);

        List<RouteStop> allRouteStop = new ArrayList<>();
        for(Long stopId : upStopIdList){
            allRouteStop.add(RouteStop.builder()
                    .stop(stopRepository.getReferenceById(stopId))
                    .route(route)
                    .type(StopType.UP.name())
                    .build());
        }
        for(Long stopId : downStopIdList){
            allRouteStop.add(RouteStop.builder()
                    .stop(stopRepository.getReferenceById(stopId))
                    .route(route)
                    .type(StopType.DOWN.name())
                    .build());
        }
        routeStopRepository.saveAll(allRouteStop);
        return route;
    }
    public Page<RouteResponse> getRoutePage(String arrival, String destination, String keyword, Pageable pageable){
        Jwt jwt = JwtHelper.getJwt();
        String id = jwt.getSubject();
        CompanyUser user = companyUserRepository.findById(id)
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = user.getBusCompany();

        Pageable fixedPageable = PageRequest.of(pageable.getPageNumber(), 5);
        Specification<Route> spec = Specification.where(RouteSpecification.hasArrival(arrival))
                .and(RouteSpecification.hasDestination(destination))
                .and(RouteSpecification.containsKeyword(keyword))
                .and(RouteSpecification.hasBusCompany(busCompany.getId()));
        return routeRepository.findAll(spec, fixedPageable).map(routeMapper::toRouteResponse);
    }
    public List<RouteStopResponse> getRouteStopList(Long routeId, String type){
        Jwt jwt = JwtHelper.getJwt();
        String id = jwt.getSubject();
        CompanyUser user = companyUserRepository.findById(id)
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = user.getBusCompany();
        Route route = routeRepository.findById(routeId)
                .orElseThrow(() -> new MyAppException(ErrorCode.ROUTE_NOT_EXISTED));
        if( ! busCompany.getId().equals(route.getBusCompany().getId()))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);

        return routeStopRepository.findAllByRouteIdAndType(routeId, type)
                .stream().map(routeStopMapper::toRouteStopResponse).toList();
    }
//    public List<RouteStopResponse> getStopBy(Long routeId, String type){
//        Jwt jwt = JwtHelper.getJwt();
//        String id = jwt.getSubject();
//        CompanyUser user = companyUserRepository.findById(id)
//                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
//        BusCompany busCompany = user.getBusCompany();
//        Route route = routeRepository.getReferenceById(routeId);
//        try{
//            if( ! busCompany.getId().equals(route.getBusCompany().getId()))
//                throw new MyAppException(ErrorCode.ACCESS_DENIED);
//        }catch(Exception exception){
//            throw new MyAppException(ErrorCode.COMPANY_NOT_EXISTED);
//        }
//        return routeStopRepository.findAllByRouteIdAndType(routeId, type)
//                .stream().map(routeStopMapper::toRouteStopResponse).toList();
//    }


}
