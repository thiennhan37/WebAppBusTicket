package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.TripResponse;
import com.example.BusTicket.dto.response.TripSimpleResponse;
import com.example.BusTicket.entity.BusType;
import com.example.BusTicket.entity.Trip;
import javax.annotation.processing.Generated;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-04-27T18:24:02+0700",
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
        tripResponse.id( trip.getId() );
        tripResponse.licensePlate( trip.getLicensePlate() );
        tripResponse.driver( trip.getDriver() );
        tripResponse.status( trip.getStatus() );
        tripResponse.departureTime( trip.getDepartureTime() );
        tripResponse.busType( trip.getBusType() );
        tripResponse.price( trip.getPrice() );

        return tripResponse.build();
    }

    @Override
    public TripSimpleResponse toTripSimpleResponse(Trip trip) {
        if ( trip == null ) {
            return null;
        }

        TripSimpleResponse.TripSimpleResponseBuilder tripSimpleResponse = TripSimpleResponse.builder();

        tripSimpleResponse.totalSeats( tripBusTypeTotalSeats( trip ) );
        tripSimpleResponse.id( trip.getId() );
        tripSimpleResponse.departureTime( trip.getDepartureTime() );

        return tripSimpleResponse.build();
    }

    private Long tripBusTypeTotalSeats(Trip trip) {
        if ( trip == null ) {
            return null;
        }
        BusType busType = trip.getBusType();
        if ( busType == null ) {
            return null;
        }
        Long totalSeats = busType.getTotalSeats();
        if ( totalSeats == null ) {
            return null;
        }
        return totalSeats;
    }
}
