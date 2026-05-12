package com.example.BusTicket.service;

import com.example.BusTicket.entity.TripSeat;
import com.example.BusTicket.entity.Ticket;
import com.example.BusTicket.enums.TripSeatEnum;
import com.example.BusTicket.repository.jpa.TripSeatRepository;
import com.example.BusTicket.repository.jpa.TicketRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class SeatReleaseSchedulerService {
    private final TripSeatRepository tripSeatRepository;
    private final TicketRepository ticketRepository;

    @Value("${booking.holdingSeatTime}")
    private int holdingSeatTime;

    /**
     * Chạy mỗi 1 phút để kiểm tra và khôi phục ghế đã hết hạn hold
     * Tìm các ghế có status = HELD và đã giữ quá lâu, sau đó:
     * - Xóa tickets chưa thanh toán (HOLDING)
     * - Restore status ghế về AVAILABLE
     */
    @Scheduled(fixedRate = 60000) // 60 seconds
    public void releaseExpiredHeldSeats() {
        try {
            log.info(">>> Starting seat release scheduler...");

            // Tìm tất cả ghế có status = HELD
            List<TripSeat> heldSeats = tripSeatRepository.findAllByStatus(TripSeatEnum.HELD.name());
            log.info("Found {} held seats", heldSeats.size());

            if (heldSeats.isEmpty()) {
                log.info("No held seats to release");
                return;
            }

            // Kiểm tra từng ghế
            LocalDateTime now = LocalDateTime.now();
            for (TripSeat tripSeat : heldSeats) {
                try {
                    // Lấy ticket mới nhất liên quan đến ghế này
                    var latestTicket = ticketRepository.findLatestHoldingTicketByTripSeatId(tripSeat.getId());

                    if (latestTicket != null && latestTicket.getUpdatedAt() != null) {
                        long secondsHeld = java.time.temporal.ChronoUnit.SECONDS
                                .between(latestTicket.getUpdatedAt(), now);

                        // Nếu vượt quá thời gian hold, thực hiện restore
                        if (secondsHeld > holdingSeatTime) {
                            log.info("Releasing seat {} (held for {} seconds)", tripSeat.getId(), secondsHeld);

                            // Thực hiện release trong transaction riêng
                            releaseSeatWithTicket(tripSeat, latestTicket);

                            log.info("Seat {} released successfully", tripSeat.getId());
                        }
                    }
                } catch (Exception e) {
                    log.error("Error releasing seat {}: ", tripSeat.getId(), e);
                    // Tiếp tục với ghế tiếp theo
                }
            }

            log.info("<<< Seat release scheduler completed");
        } catch (Exception e) {
            log.error("Error in seat release scheduler: ", e);
        }
    }

    /**
     * Chia thành method riêng với @Transactional
     * Propagation.REQUIRES_NEW = mỗi seat là transaction riêng
     * Nếu seat này fail, các seat khác vẫn được release
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void releaseSeatWithTicket(TripSeat tripSeat, Ticket ticket) {
        // Update ticket status thành EXPIRED (hết hạn)
        ticket.setStatus("EXPIRED");
        ticketRepository.save(ticket);

        // Restore status ghế về AVAILABLE
        tripSeat.setStatus(TripSeatEnum.AVAILABLE.name());
        tripSeatRepository.save(tripSeat);
    }
}

