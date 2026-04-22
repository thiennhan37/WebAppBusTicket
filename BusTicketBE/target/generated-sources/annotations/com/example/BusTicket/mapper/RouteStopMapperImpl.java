package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.RouteStopResponse;
import com.example.BusTicket.entity.RouteStop;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-04-22T16:04:29+0700",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 24.0.2 (Oracle Corporation)"
)
@Component
public class RouteStopMapperImpl implements RouteStopMapper {

    @Override
    public RouteStopResponse toRouteStopResponse(RouteStop routeStop) {
        if ( routeStop == null ) {
            return null;
        }

        RouteStopResponse.RouteStopResponseBuilder routeStopResponse = RouteStopResponse.builder();

        routeStopResponse.id( routeStop.getId() );
        routeStopResponse.type( routeStop.getType() );
        routeStopResponse.stop( routeStop.getStop() );

        return routeStopResponse.build();
    }
}
