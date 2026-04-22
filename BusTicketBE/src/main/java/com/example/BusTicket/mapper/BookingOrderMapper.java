package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.BookingOrderResponse;
import com.example.BusTicket.dto.response.BookingOrderSimple;
import com.example.BusTicket.entity.BookingOrder;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = {TripMapper.class})
public interface BookingOrderMapper {
    @Mapping(target = "creatingStaffId", source = "creatingStaff.id")
    @Mapping(target = "tripId", source = "trip.id")
    BookingOrderResponse toBookingOrderResponse(BookingOrder bookingOrder);
    @Mapping(target = "creatingStaffId", source = "creatingStaff.id")
    BookingOrderSimple toBookingOrderSimple(BookingOrder bookingOrder);

}
