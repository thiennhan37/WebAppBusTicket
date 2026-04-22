package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.BookingOrderResponse;
import com.example.BusTicket.dto.response.BookingOrderSimple;
import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.entity.CompanyUser;
import com.example.BusTicket.entity.Trip;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-04-22T16:04:29+0700",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 24.0.2 (Oracle Corporation)"
)
@Component
public class BookingOrderMapperImpl implements BookingOrderMapper {

    @Override
    public BookingOrderResponse toBookingOrderResponse(BookingOrder bookingOrder) {
        if ( bookingOrder == null ) {
            return null;
        }

        BookingOrderResponse.BookingOrderResponseBuilder bookingOrderResponse = BookingOrderResponse.builder();

        bookingOrderResponse.creatingStaffId( bookingOrderCreatingStaffId( bookingOrder ) );
        bookingOrderResponse.tripId( bookingOrderTripId( bookingOrder ) );
        bookingOrderResponse.id( bookingOrder.getId() );
        bookingOrderResponse.createdAt( bookingOrder.getCreatedAt() );
        bookingOrderResponse.customerName( bookingOrder.getCustomerName() );
        bookingOrderResponse.customerPhone( bookingOrder.getCustomerPhone() );
        bookingOrderResponse.customerEmail( bookingOrder.getCustomerEmail() );
        bookingOrderResponse.totalCost( bookingOrder.getTotalCost() );
        bookingOrderResponse.bookingUser( bookingOrder.getBookingUser() );

        return bookingOrderResponse.build();
    }

    @Override
    public BookingOrderSimple toBookingOrderSimple(BookingOrder bookingOrder) {
        if ( bookingOrder == null ) {
            return null;
        }

        BookingOrderSimple.BookingOrderSimpleBuilder bookingOrderSimple = BookingOrderSimple.builder();

        bookingOrderSimple.creatingStaffId( bookingOrderCreatingStaffId( bookingOrder ) );
        bookingOrderSimple.id( bookingOrder.getId() );
        bookingOrderSimple.createdAt( bookingOrder.getCreatedAt() );
        bookingOrderSimple.customerName( bookingOrder.getCustomerName() );
        bookingOrderSimple.customerPhone( bookingOrder.getCustomerPhone() );
        bookingOrderSimple.customerEmail( bookingOrder.getCustomerEmail() );
        bookingOrderSimple.totalCost( bookingOrder.getTotalCost() );

        return bookingOrderSimple.build();
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

    private String bookingOrderTripId(BookingOrder bookingOrder) {
        if ( bookingOrder == null ) {
            return null;
        }
        Trip trip = bookingOrder.getTrip();
        if ( trip == null ) {
            return null;
        }
        String id = trip.getId();
        if ( id == null ) {
            return null;
        }
        return id;
    }
}
