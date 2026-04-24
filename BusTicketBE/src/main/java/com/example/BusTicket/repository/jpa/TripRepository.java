package com.example.BusTicket.repository.jpa;

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
}


