package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.Ticket;
import com.example.BusTicket.entity.Trip;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface TripRepository extends JpaRepository<Trip, String> {
    Page<Trip> findAll(Specification specification, Pageable pageable);
    boolean existsByLicensePlateAndDepartureTime(String licensePlate, LocalDateTime departureTime);
    List<Trip> findAll(Specification specification, Sort sort);
    @Query("""
            SELECT DISTINCT t FROM Trip t\s
            JOIN TripSeat ts ON t.id = ts.trip.id
            WHERE ts.id IN :tripSeatIdList
           \s""")
    List<Trip> getTripForCancelTicket(@Param("tripSeatIdList") List<String> tripSeatIdList);

    @Query("""
            SELECT COUNT(t) FROM Trip t\s
            WHERE t.busCompany.id = :busCompanyId
            AND t.status = 'OPEN'
            AND t.departureTime >= :start\s
            AND t.departureTime < :end\s
           \s""")
    Long countActiveTrip(@Param("busCompanyId") String busCompanyId,
        @Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

    @Query("""
        SELECT t FROM Trip t
        WHERE t.busCompany.id = :busCompanyId
        AND t.status = 'OPEN'
        AND t.departureTime >= :now
        ORDER BY t.departureTime ASC
    """)
    List<Trip> getNextScheduledTripList(
            @Param("busCompanyId") String busCompanyId,
            @Param("now") LocalDateTime now,
            Pageable pageable
    );

    @Query("""
            SELECT t FROM Trip t
            WHERE t.status = 'OPEN' AND t.departureTime <= :now
            """
    )
    List<Trip> getClosedTripForUpdate(@Param("now") LocalDateTime now);

    @Query("""
            SELECT tk FROM Ticket tk
            JOIN TripSeat ts ON tk.tripSeat = ts
            JOIN trip t ON ts.trip = t AND t.id = :tripId
            JOIN FETCH BookingOrder bo ON tk.bookingOrder = bo
            WHERE tk.updatedAt = (
              SELECT MAX(t2.updatedAt)
              FROM Ticket t2
              WHERE t2.tripSeat = tk.tripSeat
            )
            """
    )
    List<Ticket> getTicketForCancelTrip(@Param("tripId") String tripId);
}


