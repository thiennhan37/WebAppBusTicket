package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.RouteResponse;
import com.example.BusTicket.dto.response.TripResponse;
import com.example.BusTicket.entity.Route;
import com.example.BusTicket.entity.Trip;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = {RouteMapper.class})
public interface TripMapper {
    @Mapping(target = "route", source = "route")
    @Mapping(target = "busType", source = "busType.name")
//    @Mapping(target = "id", source = "id")
    TripResponse toTripResponse(Trip trip);


}
