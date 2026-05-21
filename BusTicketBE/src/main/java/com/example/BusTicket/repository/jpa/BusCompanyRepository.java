package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.dto.response.DetailRatingResponse;
import com.example.BusTicket.dto.response.companyReport.RevenueByDate;
import com.example.BusTicket.entity.BusCompany;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface BusCompanyRepository extends JpaRepository<BusCompany, String> {
    boolean existsByEmail(String email);
    boolean existsByHotline(String hotline);
    Page<BusCompany> findAll(Specification<BusCompany> specification, Pageable fixedPageable);
    @Query("""
        SELECT SUM(ts.price) FROM Trip t
        JOIN TripSeat ts ON t.id = ts.trip.id
        WHERE t.status != 'CANCELLED' 
        AND t.busCompany.id = :busCompanyId 
        AND ts.status = 'BOOKED'
        AND departureTime >= :start AND departureTime < :end
       """)
    Long getRevenueInMonth(@Param("busCompanyId") String busCompanyId,
                          @Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

    @Query("""
        SELECT SUM(ts.price) FROM Trip t
        JOIN TripSeat ts ON t.id = ts.trip.id
        WHERE t.status != 'CANCELLED' 
        AND ts.status = 'BOOKED'
        AND departureTime >= :start AND departureTime < :end
       """)
    Long getSystemRevenueInMonth(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

    @Query(value = """
        SELECT bc.company_name as companyName,
               COUNT(ts.id) as ticketCount,
               CAST(SUM(ts.price) AS SIGNED) as amount
        FROM bus_company bc
        JOIN trip t ON bc.id = t.bus_company_id
        JOIN trip_seat ts ON t.id = ts.trip_id
        WHERE t.status != 'CANCELLED'
          AND ts.status = 'BOOKED'
        GROUP BY bc.id, bc.company_name
        ORDER BY amount DESC
        LIMIT 7
    """, nativeQuery = true)
    List<Object[]> getTop7CompaniesByRevenue();

    @Query(value = """
            SELECT  DATE(t.departure_time) as date,\s
                    CAST(SUM(ts.price) AS SIGNED) as revenue
            FROM trip t
            JOIN trip_seat ts ON t.id = ts.trip_id
            WHERE t.bus_company_id = :busCompanyId
                AND t.departure_time >= :startWeek
                AND t.departure_time < :endWeek
                AND t.status = 'CLOSED'
                AND ts.status = 'BOOKED'
            GROUP BY DATE(t.departure_time)
            ORDER BY DATE(t.departure_time)
       \s""", nativeQuery = true)
    List<RevenueByDate> getRevenueWeekList(@Param("busCompanyId") String busCompanyId,
                                           @Param("startWeek") LocalDateTime startWeek, @Param("endWeek") LocalDateTime endWeek);

    @Query(value = """
    SELECT
        AVG(r.service_quality) AS serviceQualityAvg,
        AVG(r.punctuality) AS punctualityAvg,
        AVG(r.safety) AS safetyAvg,
        AVG(r.cleanliness) AS cleanlinessAvg,
        COUNT(r.id) AS ratingCount
    FROM trip_rating r
    WHERE r.bus_company_id = :busCompanyId
    """, nativeQuery = true)
    List<Object[]> getCompanyRating(String busCompanyId);


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
        WHERE tr.busCompany.id = :busCompanyId
          AND (:avgStars IS NULL OR FLOOR(tr.averageStars) = :avgStars)
    """)
    Page<DetailRatingResponse> getDetailRatings(@Param("busCompanyId") String busCompanyId,
                                                Integer avgStars, Pageable pageable);

}
