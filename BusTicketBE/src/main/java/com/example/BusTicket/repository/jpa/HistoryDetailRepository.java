package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.HistoryBooking;
import com.example.BusTicket.entity.HistoryDetail;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HistoryDetailRepository extends JpaRepository<HistoryDetail, Long> {

}
