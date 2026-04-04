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
}
