package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.Trip;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TripRepository extends JpaRepository<Trip, String> {
    Page<Trip> findAll(Specification specification, Pageable pageable);
}

