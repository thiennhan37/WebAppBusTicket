package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.Ticket;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TicketRepository extends JpaRepository<Ticket, String> {
    @Query("""
    SELECT t FROM Ticket t WHERE t.tripSeat.trip.id = :tripId
    """)
    List<Ticket> findAllByTripId(@Param("tripId") String tripId);

//    @Query("""
//        SELECT t
//        FROM Ticket t
//        WHERE t.tripSeat.id IN :tripSeatIds
//          AND t.status IN ('HOLDING','PAID')
//          AND t.createdAt = (
//              SELECT MAX(t2.createdAt)
//              FROM Ticket t2
//              WHERE t2.tripSeat.id = t.tripSeat.id
//                AND t2.status IN ('HOLDING','PAID')
//          )
//    """)
//    List<Ticket> findLatestTickets(@Param("tripSeatIds") List<String> tripSeatIds);
}


