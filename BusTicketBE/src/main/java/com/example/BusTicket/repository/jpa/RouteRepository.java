package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.Route;
import com.example.BusTicket.entity.Stop;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RouteRepository extends JpaRepository<Route, Long> {
    Page<Route> findAll(Specification specification, Pageable pageable);
    List<Route> findAll();
}
