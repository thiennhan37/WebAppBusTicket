package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.entity.Trip;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;

@Repository
public interface BookingOrderRepository extends JpaRepository<BookingOrder, String> {

}


