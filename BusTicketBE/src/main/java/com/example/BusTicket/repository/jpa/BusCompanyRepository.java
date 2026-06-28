package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.dto.response.DetailRatingResponse;
import com.example.BusTicket.dto.response.companyReport.RevenueByDate;
import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.Customer;
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
        SELECT SUM(t.price) FROM Ticket t
        WHERE t.status = 'PAID'
        AND t.updatedAt >= :start AND t.updatedAt < :end
       """)
    Long getSystemRevenueInMonth(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

    @Query(value = """
    SELECT bc.company_name as companyName,
           COUNT(ts.id) as ticketCount,
           CAST(SUM(CASE
                    WHEN ts.status = 'BOOKED' THEN ts.price
                    ELSE 0
                    END) AS SIGNED) as amount
    FROM bus_company bc
    JOIN trip t ON bc.id = t.bus_company_id
    JOIN trip_seat ts ON t.id = ts.trip_id
    WHERE t.status != 'CANCELLED'
      AND ts.status != 'AVAILABLE'
    GROUP BY bc.id, bc.company_name
    ORDER BY amount DESC
    LIMIT 7
""", nativeQuery = true)
    List<Object[]> getTop7CompaniesByRevenue();

    @Query(value = """
            SELECT  DATE(tk.updated_at) as date,\s
                    CAST(SUM(tk.price) AS SIGNED) as revenue
            FROM ticket tk
            JOIN booking_order bo ON tk.booking_order_id = bo.id
            JOIN trip t ON bo.trip_id = t.id
            WHERE t.bus_company_id = :busCompanyId
                AND tk.updated_at >= :startWeek
                AND tk.updated_at < :endWeek
                AND tk.status = 'PAID'
            GROUP BY DATE(tk.updated_at)
            ORDER BY DATE(tk.updated_at)
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

    List<BusCompany> findByStatus(String status);
    @Query("""
        SELECT DISTINCT bc
        FROM BusCompany bc
        JOIN Trip t ON t.busCompany.id = bc.id
        JOIN Route r ON t.route.id = r.id
        WHERE bc.status = 'ACTIVE'
          AND (r.arrivalProvince.id = :provinceId OR r.destinationProvince.id = :provinceId)
    """)
    List<BusCompany> findActiveCompaniesByProvinceId(@Param("provinceId") String provinceId);

    @Query("""
    SELECT DISTINCT bo.bookingUser
    FROM BookingOrder bo
    WHERE bo.trip.busCompany.id = :busCompanyId
      AND bo.bookingUser.phone LIKE CONCAT('%', :phone, '%')
""")
    List<Customer> getCustomerForChat(
            String busCompanyId,
            String phone,
            Pageable pageable
    );

    @Query("""
        SELECT bc.id, bc.companyName, bc.avatarUrl, bc.email, bc.hotline, COALESCE(AVG(tr.averageStars), 0.0), COUNT(tr.id)
        FROM BusCompany bc
        LEFT JOIN TripRating tr ON tr.busCompany.id = bc.id
        WHERE bc.status = 'ACTIVE'
        GROUP BY bc.id, bc.companyName, bc.avatarUrl, bc.email, bc.hotline
        ORDER BY COALESCE(AVG(tr.averageStars), 0.0) DESC, COUNT(tr.id) DESC
    """)
    List<Object[]> getCompaniesWithHighRatingRaw();
}
