package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.TripResponse;
import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.BusType;
import com.example.BusTicket.entity.Route;
import com.example.BusTicket.entity.Trip;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-04-09T21:03:18+0700",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 24.0.2 (Oracle Corporation)"
)
@Component
public class TripMapperImpl implements TripMapper {

    @Override
    public TripResponse toTripResponse(Trip trip) {
        if ( trip == null ) {
            return null;
        }

        TripResponse.TripResponseBuilder tripResponse = TripResponse.builder();

        tripResponse.routeId( tripRouteId( trip ) );
        tripResponse.busCompanyId( tripBusCompanyId( trip ) );
        tripResponse.busTypeId( tripBusTypeId( trip ) );
        tripResponse.licensePlate( trip.getLicensePlate() );
        tripResponse.driver( trip.getDriver() );
        tripResponse.status( trip.getStatus() );
        tripResponse.departureTime( trip.getDepartureTime() );
        tripResponse.price( trip.getPrice() );

        return tripResponse.build();
    }

    private Long tripRouteId(Trip trip) {
        if ( trip == null ) {
            return null;
        }
        Route route = trip.getRoute();
        if ( route == null ) {
            return null;
        }
        Long id = route.getId();
        if ( id == null ) {
            return null;
        }
        return id;
    }

    private String tripBusCompanyId(Trip trip) {
        if ( trip == null ) {
            return null;
        }
        BusCompany busCompany = trip.getBusCompany();
        if ( busCompany == null ) {
            return null;
        }
        String id = busCompany.getId();
        if ( id == null ) {
            return null;
        }
        return id;
    }

    private Long tripBusTypeId(Trip trip) {
        if ( trip == null ) {
            return null;
        }
        BusType busType = trip.getBusType();
        if ( busType == null ) {
            return null;
        }
        Long id = busType.getId();
        if ( id == null ) {
            return null;
        }
        return id;
    }
}
