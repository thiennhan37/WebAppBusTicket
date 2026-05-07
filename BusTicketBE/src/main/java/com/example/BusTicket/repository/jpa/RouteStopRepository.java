package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.RouteStop;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RouteStopRepository extends JpaRepository<RouteStop, Long> {
    @Query("""
           SELECT COUNT(s) FROM Stop s
           WHERE s.id IN :ids AND s.province.id = :provinceId
           """)
    long countValidStop(@Param("ids") List<Long> ids, @Param("provinceId") String provinceId);
    
    List<RouteStop> findAllByRouteIdAndType(Long routeId, String type);
    
    /**
     * Lấy bến khởi hành của một tuyến đường
     */
    @Query("""
        SELECT rs.stop.name
        FROM RouteStop rs
        WHERE rs.route.id = :routeId AND rs.type = 'UP'
        ORDER BY rs.id ASC
        LIMIT 1
    """)
    String getDepartureStation(@Param("routeId") Integer routeId);
    
    /**
     * Lấy bến đến của một tuyến đường
     */
    @Query("""
        SELECT rs.stop.name
        FROM RouteStop rs
        WHERE rs.route.id = :routeId AND rs.type = 'DOWN'
        ORDER BY rs.id DESC
        LIMIT 1
    """)
    String getArrivalStation(@Param("routeId") Integer routeId);
}
