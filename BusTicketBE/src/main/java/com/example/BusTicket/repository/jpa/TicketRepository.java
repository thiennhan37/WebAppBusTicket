package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.Ticket;
import com.example.BusTicket.entity.TripSeat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
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

    @Modifying
    @Query("""
            UPDATE Ticket t SET t.status = :status
            WHERE t.id IN :ids AND t.status = :prevStatus
            """)
    int updateStatusByIds(@Param("ids") List<String> ids, @Param("status") String status, @Param("prevStatus") String prevStatus);

}


