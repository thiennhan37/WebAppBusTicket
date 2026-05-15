package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.Ticket;
import com.example.BusTicket.entity.TripSeat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.security.core.parameters.P;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface TicketRepository extends JpaRepository<Ticket, String> {
    @Query("""
    SELECT t FROM Ticket t WHERE t.tripSeat.trip.id = :tripId
    """)
    List<Ticket> findAllByTripId(@Param("tripId") String tripId);

    @Modifying
    @Query("""
            UPDATE Ticket t SET t.status = :status
            WHERE t.id IN :ids AND t.status IN :prevStatusList\s
           \s""")
    int updateStatusByIds(@Param("ids") List<String> ids, @Param("status") String status,
                          @Param("prevStatusList") List<String> prevStatusList, @Param("updatedAt") LocalDateTime updatedAt);

    @Query("""
        SELECT t FROM Ticket t
        JOIN FETCH t.tripSeat ts
        WHERE t.bookingOrder.id = :bookingOrderId
            AND t.status = 'HOLDING'
            AND t.updatedAt = (
              SELECT MAX(t2.updatedAt)
              FROM Ticket t2
              WHERE t2.bookingOrder.id = :bookingOrderId AND t2.tripSeat.id = t.tripSeat.id
            )
    """)
    List<Ticket> getTicketsBecomeSuccessfulPayment(@Param("bookingOrderId") String bookingOrderId);

    @Query("""
        SELECT t FROM Ticket t
        WHERE t.status = 'PAID' AND t.id IN :ticketIds
    """)
    List<Ticket> getTicketListForCancel(@Param("ticketIds") List<String> ticketIds);

    @Query("""
        SELECT t.status as status, count(t.id) FROM Ticket t
        WHERE t.bookingOrder.createdAt >= :start AND t.bookingOrder.createdAt < :end
        AND t.bookingOrder.trip.busCompany.id = :busCompanyId
        GROUP BY t.status
    """)
    List<Object[]> countByStatusInMonth(@Param("busCompanyId") String busCompanyId,
        @Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

    @Query("""
        SELECT\s
        SUM(CASE WHEN t.bookingOrder.creatingStaff IS NULL THEN 1 ELSE 0 END),
        SUM(CASE WHEN t.bookingOrder.creatingStaff IS NOT NULL THEN 1 ELSE 0 END)
        FROM Ticket t
        WHERE t.status IN :statusList
        AND t.bookingOrder.createdAt >= :start
        AND t.bookingOrder.createdAt < :end
        AND t.bookingOrder.trip.busCompany.id = :busCompanyId
    """)
    Object[] countByIssuerInMonth(@Param("busCompanyId") String busCompanyId,
            @Param("start") LocalDateTime start, @Param("end") LocalDateTime end,
            @Param("statusList") List<String> statusList);


    @Query("""
        SELECT t FROM Ticket t
        WHERE t.tripSeat.id = :tripSeatId
            AND t.status IN ('HOLDING', 'PAID')
        ORDER BY t.updatedAt DESC
        LIMIT 1
    """)
    Ticket findLatestHoldingTicketByTripSeatId(@Param("tripSeatId") String tripSeatId);
}
