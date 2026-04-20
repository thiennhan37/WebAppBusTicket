package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.BookingOrderResponse;
import com.example.BusTicket.dto.response.TripResponse;
import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.entity.Trip;
import org.hibernate.boot.internal.Target;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = {TripMapper.class})
public interface OrderMapper {
    @Mapping(target = "creatingStaffId", source = "creatingStaff.id")
    BookingOrderResponse toBookingOrderResponse(BookingOrder bookingOrder);


}
