package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.RouteResponse;
import com.example.BusTicket.dto.response.RouteStopResponse;
import com.example.BusTicket.entity.Route;
import com.example.BusTicket.entity.RouteStop;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface RouteStopMapper {
    RouteStopResponse toRouteStopResponse(RouteStop routeStop);


}
