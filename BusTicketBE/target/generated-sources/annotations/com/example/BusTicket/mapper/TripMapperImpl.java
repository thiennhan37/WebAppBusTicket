package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.TripResponse;
import com.example.BusTicket.entity.BusType;
import com.example.BusTicket.entity.Trip;
import javax.annotation.processing.Generated;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-04-15T20:04:11+0700",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 24.0.2 (Oracle Corporation)"
)
@Component
public class TripMapperImpl implements TripMapper {

    @Autowired
    private RouteMapper routeMapper;

    @Override
    public TripResponse toTripResponse(Trip trip) {
        if ( trip == null ) {
            return null;
        }

        TripResponse.TripResponseBuilder tripResponse = TripResponse.builder();

        tripResponse.route( routeMapper.toRouteResponse( trip.getRoute() ) );
        tripResponse.busType( tripBusTypeName( trip ) );
        tripResponse.id( trip.getId() );
        tripResponse.licensePlate( trip.getLicensePlate() );
        tripResponse.driver( trip.getDriver() );
        tripResponse.status( trip.getStatus() );
        tripResponse.departureTime( trip.getDepartureTime() );
        tripResponse.price( trip.getPrice() );

        return tripResponse.build();
    }

    private String tripBusTypeName(Trip trip) {
        if ( trip == null ) {
            return null;
        }
        BusType busType = trip.getBusType();
        if ( busType == null ) {
            return null;
        }
        String name = busType.getName();
        if ( name == null ) {
            return null;
        }
        return name;
    }
}
