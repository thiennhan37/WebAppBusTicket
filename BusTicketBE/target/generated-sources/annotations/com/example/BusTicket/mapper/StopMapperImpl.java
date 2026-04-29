package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.StopResponse;
import com.example.BusTicket.entity.Stop;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-04-24T20:57:10+0700",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 24.0.2 (Oracle Corporation)"
)
@Component
public class StopMapperImpl implements StopMapper {

    @Override
    public StopResponse toStopResponse(Stop stop) {
        if ( stop == null ) {
            return null;
        }

        StopResponse.StopResponseBuilder stopResponse = StopResponse.builder();

        stopResponse.id( stop.getId() );
        stopResponse.name( stop.getName() );
        stopResponse.address( stop.getAddress() );

        return stopResponse.build();
    }
}
