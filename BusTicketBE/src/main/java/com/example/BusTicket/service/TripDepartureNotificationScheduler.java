package com.example.BusTicket.service;

import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.entity.Route;
import com.example.BusTicket.entity.Trip;
import com.example.BusTicket.repository.jpa.BookingOrderRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class TripDepartureNotificationScheduler {
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");
    private static final Duration REMINDER_LOCK_TTL = Duration.ofDays(3);
    private static final Duration SCAN_WINDOW = Duration.ofMinutes(1);
    private static final List<ReminderConfig> REMINDERS = List.of(
            new ReminderConfig("1_DAY", Duration.ofDays(1), "Chuyến đi khởi hành sau 1 ngày"),
            new ReminderConfig("1_HOUR", Duration.ofHours(1), "Chuyến đi khởi hành sau 1 giờ")
    );

    private final BookingOrderRepository bookingOrderRepository;
    private final NotificationSocketService notificationSocketService;
    private final RedisTemplate<String, String> redisTemplate;
    private final FcmNotificationService fcmNotificationService;

    @Scheduled(fixedRate = 10000)
    public void sendDepartureReminders() {
        LocalDateTime now = LocalDateTime.now();
        for (ReminderConfig reminder : REMINDERS) {
            LocalDateTime start = now.plus(reminder.beforeDeparture());
            LocalDateTime end = start.plus(SCAN_WINDOW);
            sendReminderForWindow(reminder, start, end);
        }
    }

    private void sendReminderForWindow(ReminderConfig reminder, LocalDateTime start, LocalDateTime end) {
        List<BookingOrder> orders = bookingOrderRepository.findPaidCustomerOrdersDepartingBetween(start, end);
        for (BookingOrder order : orders) {
            try {
                if (order.getBookingUser() == null || order.getTrip() == null) {
                    continue;
                }
                String lockKey = "notification:trip-reminder:" + reminder.code() + ":" + order.getId();
                Boolean firstSend = redisTemplate.opsForValue()
                        .setIfAbsent(lockKey, "1", REMINDER_LOCK_TTL);
                if (!Boolean.TRUE.equals(firstSend)) {
                    continue;
                }
                notifyCustomer(order, reminder);
            } catch (Exception e) {
                log.error("Error sending trip departure reminder for booking order {}", order.getId(), e);
            }
        }
    }

    private void notifyCustomer(BookingOrder order, ReminderConfig reminder) {
        Trip trip = order.getTrip();
        Route route = trip.getRoute();
        String routeName = route != null ? route.getName() : null;
        String departureText = trip.getDepartureTime() != null
                ? trip.getDepartureTime().format(DATE_TIME_FORMATTER)
                : "";

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("bookingOrderId", order.getId());
        data.put("tripId", trip.getId());
        data.put("routeName", routeName);
        data.put("departureTime", trip.getDepartureTime());
        data.put("reminder", reminder.code());
        data.put("remainingSeconds", reminder.beforeDeparture().toSeconds());

        String message = routeName == null || routeName.isBlank()
                ? "Chuyến đi của bạn sẽ khởi hành lúc " + departureText + "."
                : "Chuyến " + routeName + " sẽ khởi hành lúc " + departureText + ".";
        String customerId = order.getBookingUser().getId();
        notificationSocketService.notifyCustomer(
                customerId,
                "TRIP_DEPARTURE_REMINDER",
                reminder.title(),
                message,
                data
        );
        fcmNotificationService.sendToCustomer(
                customerId,
                "TRIP_DEPARTURE_REMINDER",
                reminder.title(),
                message,
                data
        );
    }


    public void sendDepartureRemindersForOrder(BookingOrder order) {
        if (order == null || order.getTrip() == null || order.getTrip().getDepartureTime() == null
                || order.getBookingUser() == null) {
            return;
        }
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime departure = order.getTrip().getDepartureTime();
        long secondsUntilDeparture = java.time.temporal.ChronoUnit.SECONDS.between(now, departure);

        for (ReminderConfig reminder : REMINDERS) {
            long targetSeconds = reminder.beforeDeparture().toSeconds();
            long windowStart = targetSeconds;
            long windowEnd = targetSeconds + SCAN_WINDOW.toSeconds();
            if (secondsUntilDeparture >= windowStart && secondsUntilDeparture <= windowEnd) {
                String lockKey = "notification:trip-reminder:" + reminder.code() + ":" + order.getId();
                Boolean firstSend = redisTemplate.opsForValue()
                        .setIfAbsent(lockKey, "1", REMINDER_LOCK_TTL);
                if (Boolean.TRUE.equals(firstSend)) {
                    notifyCustomer(order, reminder);
                }
            }
        }
    }

    private record ReminderConfig(String code, Duration beforeDeparture, String title) {
    }
}
