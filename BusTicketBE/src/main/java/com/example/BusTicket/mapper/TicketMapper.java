package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.TicketResponse;
import com.example.BusTicket.dto.response.TripResponse;
import com.example.BusTicket.dto.response.TripSimpleResponse;
import com.example.BusTicket.entity.Ticket;
import com.example.BusTicket.entity.Trip;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = {BookingOrderMapper.class})
public interface TicketMapper {
    @Mapping(target = "arrivalStop", source = "arrival.stop.name")
    @Mapping(target = "destinationStop", source = "destination.stop.name")
    TicketResponse toTicketResponse(Ticket ticket);


}
