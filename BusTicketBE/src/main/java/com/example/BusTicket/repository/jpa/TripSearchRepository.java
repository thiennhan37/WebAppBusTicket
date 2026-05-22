package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.Trip;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Repository
public interface TripSearchRepository extends JpaRepository<Trip, String> {

    /**
     * Query 1: Lấy danh sách trip dựa trên tỉnh khởi hành, tỉnh đến, và ngày đi
     */
    @Query("""
        SELECT t.id, 
               t.departureTime,
               r.name,
               bc.companyName,
               t.price
        FROM Trip t
        JOIN Route r ON t.route.id = r.id
        JOIN BusCompany bc ON t.busCompany.id = bc.id
        WHERE r.arrivalProvince.id = :departureProvinceId
          AND r.destinationProvince.id = :arrivalProvinceId
          AND DATE(t.departureTime) = :departureDate
          AND t.status IN ('SCHEDULED', 'OPEN')
          AND (:minPrice IS NULL OR t.price >= :minPrice)
          AND (:maxPrice IS NULL OR t.price <= :maxPrice)
          AND (:busCompanyId IS NULL OR bc.id = :busCompanyId)
          AND (:departureTimeFrom IS NULL OR FUNCTION('TIME', t.departureTime) >= :departureTimeFrom)
          AND (:departureTimeTo IS NULL OR FUNCTION('TIME', t.departureTime) <= :departureTimeTo)
        ORDER BY
          CASE WHEN :sortBy = 'price_asc' THEN t.price END ASC,
          CASE WHEN :sortBy = 'price_desc' THEN t.price END DESC,
          CASE WHEN :sortBy = 'departure_desc' THEN t.departureTime END DESC,
          t.departureTime ASC
    """)
    List<Object[]> searchTrips(
            @Param("departureProvinceId") String departureProvinceId,
            @Param("arrivalProvinceId") String arrivalProvinceId,
            @Param("departureDate") LocalDate departureDate,
            @Param("minPrice") Integer minPrice,
            @Param("maxPrice") Integer maxPrice,
            @Param("busCompanyId") String busCompanyId,
            @Param("departureTimeFrom") LocalTime departureTimeFrom,
            @Param("departureTimeTo") LocalTime departureTimeTo,
            @Param("sortBy") String sortBy
    );

    /**
     * Query 2: Lấy số ghế available cho một chuyến xe cụ thể
     */
    @Query("""
        SELECT COUNT(ts.id)
        FROM TripSeat ts
        WHERE ts.trip.id = :tripId
          AND ts.status = 'AVAILABLE'
    """)
    int getAvailableSeatsCount(@Param("tripId") String tripId);

    /**
     * Query 5: Lấy rating và review count (trả về default nếu không có review table)
     */
    @Query("""
        SELECT COALESCE(AVG(CAST(4.5 as double)), 0.0) as rating,
               COUNT(bc.id) as reviewCount
        FROM BusCompany bc
        WHERE bc.id = :busCompanyId
        GROUP BY bc.id
    """)
    List<Object[]> getCompanyRatings(@Param("busCompanyId") String busCompanyId);
}


