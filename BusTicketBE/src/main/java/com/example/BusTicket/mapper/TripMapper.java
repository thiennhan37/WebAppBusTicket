package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.TripResponse;
import com.example.BusTicket.dto.response.TripSimpleResponse;
import com.example.BusTicket.entity.Trip;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = {RouteMapper.class})
public interface TripMapper {
    @Mapping(target = "route", source = "route")
    TripResponse toTripResponse(Trip trip);
    @Mapping(target = "totalSeats", source = "busType.totalSeats")
    TripSimpleResponse toTripSimpleResponse(Trip trip);

}
