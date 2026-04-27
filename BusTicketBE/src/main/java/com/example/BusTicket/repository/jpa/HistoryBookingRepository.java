package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.HistoryBooking;
import com.example.BusTicket.entity.Stop;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HistoryBookingRepository extends JpaRepository<HistoryBooking, Long> {

}
