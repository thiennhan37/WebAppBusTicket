package com.example.BusTicket.service;

import com.example.BusTicket.entity.TripSeat;
import com.example.BusTicket.entity.Ticket;
import com.example.BusTicket.enums.TripSeatEnum;
import com.example.BusTicket.enums.TicketStatusEnum;
import com.example.BusTicket.repository.jpa.TripSeatRepository;
import com.example.BusTicket.repository.jpa.TicketRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class SeatReleaseTxService {
    private final TripSeatRepository tripSeatRepository;
    private final TicketRepository ticketRepository;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void releaseSeatWithTicket(TripSeat tripSeat, Ticket ticket) {
        ticket.setStatus(TicketStatusEnum.EXPIRED.name());
        ticketRepository.save(ticket);

        tripSeat.setStatus(TripSeatEnum.AVAILABLE.name());
        tripSeatRepository.save(tripSeat);
    }
}