package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.Payment;
import com.example.BusTicket.entity.TripSeat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, String> {
    @Modifying
    @Query("""
        UPDATE Payment p
        SET p.status = 'SUCCESSFUL'
        WHERE p.id = :id
          AND p.status = 'PENDING'
    """)
    int updateToSuccess(@Param("id") String id);

    Payment findByBookingOrderIdAndType(String bookingOrderId, String type);
}


