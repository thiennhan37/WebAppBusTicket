package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.dto.response.report.RevenueByDate;
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
        WHERE t.status != 'CANCELLED'\s
        AND t.busCompany.id = :busCompanyId\s
        AND ts.status = 'BOOKED'
        AND departureTime >= :start AND departureTime < :end
       \s""")
    Long getRevenueInMonth(@Param("busCompanyId") String busCompanyId,
                          @Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

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


}
