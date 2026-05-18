package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.TripRating;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TripRatingRepository extends JpaRepository<TripRating, Long> {
    boolean existsByBookingOrderId(String bookingOrderId);

    @Query("""
        SELECT COALESCE(AVG(tr.averageStars), 0.0), COUNT(tr.id)
        FROM TripRating tr
        WHERE tr.busCompany.id = :companyId
    """)
    List<Object[]> getCompanyRatingSummary(@Param("companyId") String companyId);
}