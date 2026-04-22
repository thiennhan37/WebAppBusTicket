package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.TicketResponse;
import com.example.BusTicket.entity.RouteStop;
import com.example.BusTicket.entity.Stop;
import com.example.BusTicket.entity.Ticket;
import javax.annotation.processing.Generated;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-04-22T16:04:29+0700",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 24.0.2 (Oracle Corporation)"
)
@Component
public class TicketMapperImpl implements TicketMapper {

    @Autowired
    private BookingOrderMapper bookingOrderMapper;

    @Override
    public TicketResponse toTicketResponse(Ticket ticket) {
        if ( ticket == null ) {
            return null;
        }

        TicketResponse.TicketResponseBuilder ticketResponse = TicketResponse.builder();

        ticketResponse.arrivalStop( ticketArrivalStopName( ticket ) );
        ticketResponse.destinationStop( ticketDestinationStopName( ticket ) );
        ticketResponse.id( ticket.getId() );
        ticketResponse.price( ticket.getPrice() );
        ticketResponse.status( ticket.getStatus() );
        ticketResponse.updatedAt( ticket.getUpdatedAt() );
        ticketResponse.bookingOrder( bookingOrderMapper.toBookingOrderSimple( ticket.getBookingOrder() ) );

        return ticketResponse.build();
    }

    private String ticketArrivalStopName(Ticket ticket) {
        if ( ticket == null ) {
            return null;
        }
        RouteStop arrival = ticket.getArrival();
        if ( arrival == null ) {
            return null;
        }
        Stop stop = arrival.getStop();
        if ( stop == null ) {
            return null;
        }
        String name = stop.getName();
        if ( name == null ) {
            return null;
        }
        return name;
    }

    private String ticketDestinationStopName(Ticket ticket) {
        if ( ticket == null ) {
            return null;
        }
        RouteStop destination = ticket.getDestination();
        if ( destination == null ) {
            return null;
        }
        Stop stop = destination.getStop();
        if ( stop == null ) {
            return null;
        }
        String name = stop.getName();
        if ( name == null ) {
            return null;
        }
        return name;
    }
}
