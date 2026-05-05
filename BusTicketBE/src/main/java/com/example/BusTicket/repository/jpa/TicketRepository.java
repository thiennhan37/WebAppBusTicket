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
            WHERE t.id IN :ids AND t.status = :prevStatus 
            """)
    int updateStatusByIds(@Param("ids") List<String> ids, @Param("status") String status,
                          @Param("prevStatus") String prevStatus, @Param("updatedAt") LocalDateTime updatedAt);

    @Query("""
        SELECT t FROM Ticket t
        WHERE t.status = 'HOLDING'
            AND t.bookingOrder.id = :bookingOrderId
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
}


