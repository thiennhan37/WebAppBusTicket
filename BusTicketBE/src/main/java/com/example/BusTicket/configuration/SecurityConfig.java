package com.example.BusTicket.configuration;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;


@Configuration
@EnableWebSecurity //Bật cơ chế security của Spring, Nếu không có → tất cả API đều public
@EnableMethodSecurity // cho phép dùng preAuthorize, postAuthorize
public class SecurityConfig {
    private final String[] PUBLIC_ENDPOINTS = {"/nhaxe/auth/login", "/nhaxe/auth/logout", "/nhaxe/auth/refreshToken"};
    private final String[] ADMIN_ENDPOINTS = {"/users"};

    @Autowired
    private CustomJwtDecoder customJwtDecoder;
    @Autowired
    private JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity httpSecurity){
        httpSecurity.cors(Customizer.withDefaults()); // Bật CORS
        httpSecurity.authorizeHttpRequests(request ->
                request.requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        // Browser gửi OPTIONS trước (CORS)
                        .requestMatchers(HttpMethod.POST, PUBLIC_ENDPOINTS).permitAll()


                        .anyRequest().authenticated()
                        //Tất cả API khác → bắt buộc có JWT
        );
        httpSecurity.oauth2ResourceServer(oAuth2 ->
                oAuth2.jwt(jwtConfigurer ->
                                jwtConfigurer.decoder(customJwtDecoder)


                        )
                        .authenticationEntryPoint(jwtAuthenticationEntryPoint)
        );

        httpSecurity.csrf(AbstractHttpConfigurer::disable);
        return httpSecurity.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
