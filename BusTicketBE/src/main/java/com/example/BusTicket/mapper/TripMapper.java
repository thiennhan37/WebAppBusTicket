package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.RouteResponse;
import com.example.BusTicket.dto.response.TripResponse;
import com.example.BusTicket.entity.Route;
import com.example.BusTicket.entity.Trip;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface TripMapper {
    @Mapping(target = "routeId", source = "route.id")
    @Mapping(target = "busCompanyId", source = "busCompany.id")
    @Mapping(target = "busTypeId", source = "busType.id")
    TripResponse toTripResponse(Trip trip);


}
