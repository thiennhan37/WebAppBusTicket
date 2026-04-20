package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.TripSeat;
import org.springframework.data.jpa.repository.JpaRepository;
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
}


