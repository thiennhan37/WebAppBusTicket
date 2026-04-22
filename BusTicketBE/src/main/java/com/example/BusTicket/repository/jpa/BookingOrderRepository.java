package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.entity.Trip;
import com.example.BusTicket.entity.TripSeat;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface BookingOrderRepository extends JpaRepository<BookingOrder, String> {

}


