package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.BusType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BusTypeRepository extends JpaRepository<BusType, Long> {

}
