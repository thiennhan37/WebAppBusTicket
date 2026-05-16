package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.Route;
import com.example.BusTicket.entity.Stop;
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
public interface RouteRepository extends JpaRepository<Route, Long> {
    Page<Route> findAll(Specification specification, Pageable pageable);
    List<Route> findAll();

    @Query(value = """
        SELECT r.name, COUNT(tk.id) as ticket_count
        FROM route r
        LEFT JOIN trip t
            ON t.route_id = r.id
            AND t.status != 'CANCELLED'
            AND t.bus_company_id = :busCompanyId
        LEFT JOIN booking_order bo
            ON bo.trip_id = t.id
            AND bo.created_at >= :start
            AND bo.created_at < :end
        LEFT JOIN ticket tk ON tk.booking_order_id = bo.id AND tk.status = 'PAID'
        WHERE r.bus_company_id = :busCompanyId
        GROUP BY r.name
        ORDER BY ticket_count DESC LIMIT 4
    """, nativeQuery = true)
    List<Object[]> countTicketForHotRouteList(@Param("busCompanyId") String busCompanyId,
            @Param("start") LocalDateTime start, @Param("end") LocalDateTime end);
}
