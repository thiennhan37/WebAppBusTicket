package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.entity.Trip;
import com.example.BusTicket.entity.TripSeat;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface BookingOrderRepository extends JpaRepository<BookingOrder, String> {
    @Query("""
        SELECT DISTINCT bo FROM BookingOrder bo
        LEFT JOIN FETCH bo.trip t
        LEFT JOIN FETCH t.route r
        LEFT JOIN FETCH r.arrivalProvince
        LEFT JOIN FETCH r.destinationProvince
        LEFT JOIN FETCH t.busCompany
        WHERE bo.bookingUser.id = :customerId
          AND bo.createdAt >= :fromTime
        ORDER BY bo.createdAt DESC
    """)
    List<BookingOrder> findRecentOrdersByCustomerId(@Param("customerId") String customerId,
                                                    @Param("fromTime") LocalDateTime fromTime);
}


