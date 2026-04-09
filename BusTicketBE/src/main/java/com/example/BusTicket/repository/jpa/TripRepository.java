package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.BusType;
import com.example.BusTicket.entity.Trip;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TripRepository extends JpaRepository<Trip, String> {

}
