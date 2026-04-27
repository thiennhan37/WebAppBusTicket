package com.example.BusTicket.service;


import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SeatReservationService {
    private final RedisTemplate<String, String> redisTemplate;
    private DefaultRedisScript<Long> holdSeatsScript;
    private DefaultRedisScript<Long> deleteSeatsScript;

    @Value("${booking.holdingSeatPrefixKey}")
    private String holdingSeatPrefixKey;
    @Value("${booking.tempOrderPrefixKey}")
    private String tempOrderPrefixKey;
    @Value("${booking.compMakeOrderPrefixKey}")
    private String compMakeOrderPrefixKey;
    @PostConstruct
    public void init() {
        holdSeatsScript = new DefaultRedisScript<>();
        holdSeatsScript.setLocation(new ClassPathResource("scripts/comp_hold_seats.lua"));
        holdSeatsScript.setResultType(Long.class);

        deleteSeatsScript = new DefaultRedisScript<>();
        deleteSeatsScript.setLocation(new ClassPathResource("scripts/delete_invalid_order.lua"));
        deleteSeatsScript.setResultType(Long.class);
    }
    public boolean tryHoldSeats(String creatingStaffId, String bookingUserId, String orderId,
                                List<String> tripSeatIdList, int ttlSeconds) {
        String compMakeOrderKey = compMakeOrderPrefixKey + creatingStaffId;
        String tempOrderKey = tempOrderPrefixKey + orderId;

        List<String> keys = new ArrayList<>();
        keys.add(compMakeOrderKey);
        keys.add(tempOrderKey);
        tripSeatIdList.forEach(id -> keys.add(holdingSeatPrefixKey + id));

        List<String> argv = new ArrayList<>();
        argv.add(String.valueOf(ttlSeconds)); // ttl
        argv.add(orderId);
        argv.addAll(tripSeatIdList); // thêm danh sách các trip_seat cho order

//        String customer = bookingUserId != null ? bookingUserId : "company_booking_order";
        Long result = redisTemplate.execute(holdSeatsScript, keys, argv.toArray());
        if(result == null) throw new MyAppException(ErrorCode.ERROR_REDIS);
        return switch (result.intValue()) {
            case 1 -> true;
            case -1 -> throw new MyAppException(ErrorCode.BOOKING_ANOTHER_ORDER);
            case -2 -> throw new MyAppException(ErrorCode.ORDER_EXISTED);
            case -3 -> throw new MyAppException(ErrorCode.TRIP_SEAT_BOOKED);
            default -> throw new MyAppException(ErrorCode.ERROR_REDIS);
        };
    }
    public void deleteInvalidOrder(String creatingStaffId, String orderId, List<String> tripSeatIdList){
        String compMakeOrderKey = compMakeOrderPrefixKey + creatingStaffId;
        String tempOrderKey = tempOrderPrefixKey + orderId;

        List<String> keys = new ArrayList<>();
        keys.add(compMakeOrderKey);
        keys.add(tempOrderKey);
        tripSeatIdList.forEach(id -> keys.add(holdingSeatPrefixKey + id));
        Long result = redisTemplate.execute(deleteSeatsScript, keys, orderId);
        if(result == null) throw new MyAppException(ErrorCode.ERROR_REDIS);
    }
    public void checkValidOrder(String orderId, List<String> tripSeatIdList){
        String tempOrderKey = tempOrderPrefixKey + orderId;
        if( !Boolean.TRUE.equals(redisTemplate.hasKey(tempOrderKey)) )
            throw new MyAppException(ErrorCode.NOT_EXISTED);

        for(String tripSeatId : tripSeatIdList){
            String tripSeatKey = holdingSeatPrefixKey + tripSeatId;
            String value = redisTemplate.opsForValue().get(tripSeatKey);
            if(value == null || !value.equals(orderId)){
                throw new MyAppException(ErrorCode.TRIP_SEAT_INVALID);
            }
        }
    }

}
