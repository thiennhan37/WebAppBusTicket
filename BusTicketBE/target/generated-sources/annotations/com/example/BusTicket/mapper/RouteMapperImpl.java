package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.RouteResponse;
import com.example.BusTicket.entity.Route;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-04-22T16:04:29+0700",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 24.0.2 (Oracle Corporation)"
)
@Component
public class RouteMapperImpl implements RouteMapper {

    @Override
    public RouteResponse toRouteResponse(Route route) {
        if ( route == null ) {
            return null;
        }

        RouteResponse.RouteResponseBuilder routeResponse = RouteResponse.builder();

        routeResponse.id( route.getId() );
        routeResponse.name( route.getName() );
        routeResponse.arrivalProvince( route.getArrivalProvince() );
        routeResponse.destinationProvince( route.getDestinationProvince() );

        return routeResponse.build();
    }
}
