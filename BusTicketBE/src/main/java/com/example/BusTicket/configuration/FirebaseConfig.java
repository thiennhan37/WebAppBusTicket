package com.example.BusTicket.configuration;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.io.InputStream;

@Configuration
@Slf4j
public class FirebaseConfig {
    private static final String DEFAULT_CREDENTIAL_LOCATION = "classpath:firebase-service-account.json";

    @Bean
    public FirebaseApp firebaseApp(
            ResourceLoader resourceLoader,
            @Value("${firebase.credentials.location:}") String credentialsLocation) throws IOException {
        if (!FirebaseApp.getApps().isEmpty()) {
            return FirebaseApp.getInstance();
        }

        String location = StringUtils.hasText(credentialsLocation)
                ? credentialsLocation
                : DEFAULT_CREDENTIAL_LOCATION;
        Resource resource = resourceLoader.getResource(location);
        if (!resource.exists()) {
            throw new IllegalStateException("Firebase service account file not found at: " + location
                    + ". Configure firebase.credentials.location in application.properties or add "
                    + DEFAULT_CREDENTIAL_LOCATION + " to src/main/resources.");
        }

        try (InputStream serviceAccount = resource.getInputStream()) {
            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();
            FirebaseApp app = FirebaseApp.initializeApp(options);
            log.info("FirebaseApp initialized using credentials from {}", location);
            return app;
        }
    }
    @Bean
    public FirebaseMessaging firebaseMessaging(FirebaseApp firebaseApp) {
        return FirebaseMessaging.getInstance(firebaseApp);
    }
}