package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.request.CompanyUserCrRequest;
import com.example.BusTicket.dto.response.CompanyUserResponse;
import com.example.BusTicket.dto.response.RouteResponse;
import com.example.BusTicket.entity.CompanyUser;
import com.example.BusTicket.entity.Route;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring", uses = {StopMapper.class})
public interface RouteMapper {
    RouteResponse toRouteResponse(Route route);


}
