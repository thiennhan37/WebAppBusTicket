package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.TripSeatResponse;
import com.example.BusTicket.entity.TripSeat;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring", uses = {TicketMapper.class})
public interface TripSeatMapper {
    TripSeatResponse toTripSeatResponse(TripSeat tripSeat);


}
