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

    @Query("""
        SELECT DISTINCT bo FROM BookingOrder bo
        JOIN FETCH bo.bookingUser bu
        JOIN FETCH bo.trip t
        LEFT JOIN FETCH t.route r
        LEFT JOIN FETCH r.arrivalProvince
        LEFT JOIN FETCH r.destinationProvince
        WHERE t.status = 'OPEN'
          AND t.departureTime >= :start
          AND t.departureTime < :end
          AND EXISTS (
              SELECT 1 FROM Ticket tk
              WHERE tk.bookingOrder = bo
                AND tk.status = 'PAID'
          )
    """)
    List<BookingOrder> findPaidCustomerOrdersDepartingBetween(@Param("start") LocalDateTime start,
                                                              @Param("end") LocalDateTime end);

    @Query("""
    SELECT DISTINCT bo FROM BookingOrder bo
    JOIN FETCH bo.bookingUser
    JOIN FETCH bo.trip t
    LEFT JOIN FETCH t.route
    WHERE bo.bookingUser.id = :customerId
""")
    List<BookingOrder> findByBookingUserIdForNotification(@Param("customerId") String customerId);

    @Query("""
        SELECT CASE WHEN COUNT(p) > 0 THEN true ELSE false END
        FROM Payment p
        WHERE p.bookingOrder.id = :bookingOrderId
          AND p.status = 'SUCCESSFUL'
    """)
    boolean isBookingOrderPaid(@Param("bookingOrderId") String bookingOrderId);
}


