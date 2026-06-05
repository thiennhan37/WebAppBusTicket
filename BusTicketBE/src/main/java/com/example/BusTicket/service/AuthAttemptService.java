package com.example.BusTicket.service;

import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class AuthAttemptService {
    private static final int MAX_FAILED_ATTEMPTS = 5;
    private static final int BASE_BLOCK_MINUTES = 5;
    private static final Duration ATTEMPT_TTL = Duration.ofMinutes(30);
    private static final Duration PENALTY_TTL = Duration.ofDays(1);


    private final RedisTemplate<String, String> redisTemplate;

    public void assertNotBlocked(String scope, String identifier){
        if (Boolean.TRUE.equals(redisTemplate.hasKey(blockKey(scope, identifier)))){
            throw new MyAppException(ErrorCode.TOO_MANY_FAILED_ATTEMPTS);
        }
    }

    public void recordFailure(String scope, String identifier){
        assertNotBlocked(scope, identifier);
        String attemptsKey = attemptsKey(scope, identifier);
        Long failedAttempts = redisTemplate.opsForValue().increment(attemptsKey);
        if (failedAttempts != null && failedAttempts == 1){
            redisTemplate.expire(attemptsKey, ATTEMPT_TTL);
        }

        if (failedAttempts != null && failedAttempts >= MAX_FAILED_ATTEMPTS){
            String penaltyKey = penaltyKey(scope, identifier);
            Long penaltyLevel = redisTemplate.opsForValue().increment(penaltyKey);
            if (penaltyLevel != null && penaltyLevel == 1L){
                redisTemplate.expire(penaltyKey, PENALTY_TTL);
            }
            long blockMinutes = BASE_BLOCK_MINUTES * (penaltyLevel == null ? 1L : penaltyLevel);
            redisTemplate.opsForValue().set(blockKey(scope, identifier), "1", Duration.ofMinutes(blockMinutes));
            redisTemplate.delete(attemptsKey);
            throw new MyAppException(ErrorCode.TOO_MANY_FAILED_ATTEMPTS);
        }
    }

    public void reset(String scope, String identifier) {
        redisTemplate.delete(attemptsKey(scope, identifier));
        redisTemplate.delete(blockKey(scope, identifier));
        redisTemplate.delete(penaltyKey(scope, identifier));
    }

    private String attemptsKey(String scope, String identifier) {
        return baseKey(scope, identifier) + ":attempts";
    }

    private String blockKey(String scope, String identifier) {
        return baseKey(scope, identifier) + ":blocked";
    }

    private String penaltyKey(String scope, String identifier) {
        return baseKey(scope, identifier) + ":penalty";
    }

    private String baseKey(String scope, String identifier) {
        return "AUTH_FAIL:" + normalize(scope) + ":" + normalize(identifier);
    }

    private String normalize(String value) {
        if (value == null || value.isBlank()) {
            return "unknown";
        }
        return value.trim().toLowerCase(Locale.ROOT);
    }
}
