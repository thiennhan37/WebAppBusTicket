package com.example.BusTicket.service;

import com.example.BusTicket.entity.UserDeviceToken;
import com.example.BusTicket.repository.jpa.UserDeviceTokenRepository;
import com.google.firebase.messaging.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.Instant;
import java.time.temporal.TemporalAccessor;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class FcmNotificationService {
    private final UserDeviceTokenRepository userDeviceTokenRepository;
    private final FirebaseMessaging firebaseMessaging;

    public void sendToCustomer(String customerId, String type, String title, String message, Map<String, Object> extraData){
        List<UserDeviceToken> tokens = userDeviceTokenRepository.findAllByUser_Id(customerId);
        if (tokens.isEmpty()) return;
        Map<String, String> data = buildDataPayload(type, title, message, extraData);
        for (UserDeviceToken token : tokens) {
            sendToToken(token.getDeviceToken(), title, message, data);
        }
    }

    public Map<String, String> buildDataPayload(String type, String title, String message, Map<String, Object> extraData){
        Map<String, String> data = new LinkedHashMap<>();
        data.put("eventId", UUID.randomUUID().toString());
        data.put("type", safeString(type));
        data.put("title", safeString(title));
        data.put("message", safeString(message));
        data.put("createdAt", Instant.now().toString());

        if (extraData != null) {
            extraData.forEach((k,v)->{
               if (StringUtils.hasText(k) && v != null) {
                   data.put(k, toFcmString(v));
               }
            });
        }
        return data;
    }

    private void sendToToken(String token, String title, String body, Map<String, String> data){
        Message fcmMessage = Message.builder()
                .setToken(token)
                .setNotification(Notification.builder()
                        .setTitle(title)
                        .setBody(body)
                        .build())
                .putAllData(data)
                .setAndroidConfig(AndroidConfig.builder()
                        .setPriority(AndroidConfig.Priority.HIGH)
                        .setNotification(AndroidNotification.builder()
                                .setTitle(title)
                                .setBody(body)
                                .setChannelId("high_importance_channel")
                                .build())
                        .build())
                .setApnsConfig(ApnsConfig.builder()
                        .setAps(Aps.builder()
                                .setContentAvailable(true)
                                .build())
                        .build())
                .build();

        try {
            firebaseMessaging.send(fcmMessage);
        } catch (FirebaseMessagingException e) {
            log.error("Failed to send FCM message to token {}", token, e);
        }
    }

    private String toFcmString(Object value){
        if (value instanceof TemporalAccessor temporalAccessor){
            return java.time.format.DateTimeFormatter.ISO_DATE_TIME.format(temporalAccessor);
        }
        return String.valueOf(value);
    }

    private String safeString(String value) {
        return value == null ? "" : value;
    }
}
