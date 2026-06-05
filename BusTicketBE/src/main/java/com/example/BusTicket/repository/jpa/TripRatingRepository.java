package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.TripRating;
import com.example.BusTicket.dto.response.DetailRatingResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TripRatingRepository extends JpaRepository<TripRating, Long> {
    boolean existsByBookingOrderId(String bookingOrderId);

    @Query("""
        SELECT new com.example.BusTicket.dto.response.DetailRatingResponse(tr.id AS id,
            tr.serviceQuality AS serviceQuality,
            tr.punctuality AS punctuality,
            tr.safety AS safety,
            tr.cleanliness AS cleanliness,
            c.fullName AS customerName,
            bo.trip.route.name AS routeName,
            tr.description AS description,
            tr.averageStars AS averageStars,
            tr.createdAt AS createdAt)
        FROM TripRating tr
        JOIN tr.customer c
        JOIN tr.bookingOrder bo
        WHERE bo.id = :bookingOrderId
          AND c.id = :customerId
    """)
    Optional<DetailRatingResponse> findDetailByBookingOrderIdAndCustomerId(@Param("bookingOrderId") String bookingOrderId,
                                                                           @Param("customerId") String customerId);

    @Query("""
        SELECT COALESCE(AVG(tr.averageStars), 0.0), COUNT(tr.id)
        FROM TripRating tr
        WHERE tr.busCompany.id = :companyId
    """)
    List<Object[]> getCompanyRatingSummary(@Param("companyId") String companyId);
}
