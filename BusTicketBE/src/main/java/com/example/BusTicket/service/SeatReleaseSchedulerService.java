package com.example.BusTicket.service;

import com.example.BusTicket.entity.TripSeat;
import com.example.BusTicket.enums.TripSeatEnum;
import com.example.BusTicket.repository.jpa.TripSeatRepository;
import com.example.BusTicket.repository.jpa.TicketRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class SeatReleaseSchedulerService {
    private final TripSeatRepository tripSeatRepository;
    private final TicketRepository ticketRepository;
    private final SeatReleaseTxService seatReleaseTxService;

    @Value("${booking.holdingSeatTime}")
    private int holdingSeatTime;

    @Scheduled(fixedRate = 5000) // 60 seconds
    public void releaseExpiredHeldSeats() {
        try {
            List<TripSeat> heldSeats = tripSeatRepository.findAllByStatus(TripSeatEnum.HELD.name());
            if (heldSeats.isEmpty()) {
                return;
            }
            LocalDateTime now = LocalDateTime.now();
            for (TripSeat tripSeat : heldSeats) {
                try {
                    var latestTicket = ticketRepository.findLatestHoldingTicketByTripSeatId(tripSeat.getId());

                    // Nếu không tìm thấy ticket hoặc ticket không có booking order, skip ghế này
                    if (latestTicket == null || latestTicket.getBookingOrder() == null ) {
                         continue;
                    }

                    // Kiểm tra thời gian updated
                    if (latestTicket.getUpdatedAt() != null && latestTicket.getBookingOrder().getBookingUser() != null) {
                        long secondsHeld = java.time.temporal.ChronoUnit.SECONDS
                                .between(latestTicket.getUpdatedAt(), now);

                        if (secondsHeld > holdingSeatTime) {
                            seatReleaseTxService.releaseSeatWithTicket(tripSeat, latestTicket);
                            log.info("Seat {} released successfully after {} seconds", tripSeat.getId(), secondsHeld);
                        }
                    } else {
                        log.warn("Ticket {} has no updatedAt, skipping", latestTicket.getId());
                    }
                } catch (Exception e) {
                    log.error("Error releasing seat {}: ", tripSeat.getId(), e);
                    // Tiếp tục với ghế tiếp theo
                }
            }

//            log.info("<<< Seat release scheduler completed");
        } catch (Exception e) {
            log.error("Error in seat release scheduler: ", e);
        }
    }
}

