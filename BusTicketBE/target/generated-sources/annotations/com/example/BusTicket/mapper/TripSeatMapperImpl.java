package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.TripSeatResponse;
import com.example.BusTicket.entity.TripSeat;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-04-22T16:04:29+0700",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 24.0.2 (Oracle Corporation)"
)
@Component
public class TripSeatMapperImpl implements TripSeatMapper {

    @Override
    public TripSeatResponse toTripSeatResponse(TripSeat tripSeat) {
        if ( tripSeat == null ) {
            return null;
        }

        TripSeatResponse.TripSeatResponseBuilder tripSeatResponse = TripSeatResponse.builder();

        tripSeatResponse.id( tripSeat.getId() );
        tripSeatResponse.seat( tripSeat.getSeat() );
        tripSeatResponse.status( tripSeat.getStatus() );
        tripSeatResponse.price( tripSeat.getPrice() );

        return tripSeatResponse.build();
    }
}
