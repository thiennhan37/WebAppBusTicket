package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.TripSeat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TripSeatRepository extends JpaRepository<TripSeat, String> {
    @Query("""
            SELECT ts FROM TripSeat ts
            WHERE ts.id IN :ids AND ts.trip.id = :tripId AND ts.status = 'AVAILABLE'\s
    \s""")
    List<TripSeat> getValidTripSeatList(@Param("ids") List<String> tripSeatIdList, @Param("tripId") String tripId);

    @Query("""
        SELECT t.trip.id, COUNT(t.id) FROM TripSeat t
        WHERE t.trip.id IN :tripIds AND t.status IN ('HELD', 'BOOKED')
        GROUP BY t.trip.id
    """)
    List<Object[]> countBookedSeats(@Param("tripIds") List<String> tripIds);

    @Query("""
        SELECT  SUM(CASE WHEN t.status = 'HELD' THEN 1 ELSE 0 END),
                SUM(CASE WHEN t.status = 'BOOKED' THEN 1 ELSE 0 END)
                FROM TripSeat t WHERE t.trip.id = :tripId
    """)
    Object[] countHeldAndBooked(@Param("tripId") String tripId);

    List<TripSeat> findAllByTripId(String tripId);

    @Query("""
        SELECT ts, t
        FROM TripSeat ts
        LEFT JOIN Ticket t ON ts.status <> 'AVAILABLE'
         AND t.tripSeat.id = ts.id
         AND t.updatedAt = (
             SELECT MAX(t2.updatedAt)
             FROM Ticket t2
             WHERE t2.tripSeat.id = ts.id
               AND t2.status IN ('HOLDING','PAID')
         )
        WHERE ts.trip.id = :tripId
        """)
    List<Object[]> findSeatsWithLatestTicket(@Param("tripId") String tripId);

    @Query("""
        SELECT ts
        FROM TripSeat ts
        JOIN Ticket t ON t.tripSeat.id = ts.id
        WHERE t.id IN :ticketIds
          AND t.status IN ('HOLDING','PAID')
    """)
    List<TripSeat> getTripSeatsForCancel(@Param("ticketIds") List<String> ticketIds);

    @Modifying
    @Query("""
            UPDATE TripSeat ts SET ts.status = :status
            WHERE ts.id IN :ids AND ts.status IN :prevStatusList
            """)
    int updateStatusByIds(@Param("ids") List<String> ids,
                          @Param("status") String status, @Param("prevStatusList") List<String> prevStatusList);

}


