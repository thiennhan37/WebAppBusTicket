package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.BookingOrderResponse;
import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.entity.CompanyUser;
import javax.annotation.processing.Generated;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-04-20T10:31:39+0700",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 24.0.2 (Oracle Corporation)"
)
@Component
public class OrderMapperImpl implements OrderMapper {

    @Autowired
    private TripMapper tripMapper;

    @Override
    public BookingOrderResponse toBookingOrderResponse(BookingOrder bookingOrder) {
        if ( bookingOrder == null ) {
            return null;
        }

        BookingOrderResponse.BookingOrderResponseBuilder bookingOrderResponse = BookingOrderResponse.builder();

        bookingOrderResponse.creatingStaffId( bookingOrderCreatingStaffId( bookingOrder ) );
        bookingOrderResponse.id( bookingOrder.getId() );
        bookingOrderResponse.createdAt( bookingOrder.getCreatedAt() );
        bookingOrderResponse.customerName( bookingOrder.getCustomerName() );
        bookingOrderResponse.customerPhone( bookingOrder.getCustomerPhone() );
        bookingOrderResponse.customerEmail( bookingOrder.getCustomerEmail() );
        bookingOrderResponse.totalCost( bookingOrder.getTotalCost() );
        bookingOrderResponse.trip( tripMapper.toTripResponse( bookingOrder.getTrip() ) );
        bookingOrderResponse.bookingUser( bookingOrder.getBookingUser() );

        return bookingOrderResponse.build();
    }

    private String bookingOrderCreatingStaffId(BookingOrder bookingOrder) {
        if ( bookingOrder == null ) {
            return null;
        }
        CompanyUser creatingStaff = bookingOrder.getCreatingStaff();
        if ( creatingStaff == null ) {
            return null;
        }
        String id = creatingStaff.getId();
        if ( id == null ) {
            return null;
        }
        return id;
    }
}
