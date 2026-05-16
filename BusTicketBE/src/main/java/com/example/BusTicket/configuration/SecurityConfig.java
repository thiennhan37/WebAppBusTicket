package com.example.BusTicket.configuration;


import com.example.BusTicket.enums.RoleEnum;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;



@Configuration
@EnableWebSecurity //Bật cơ chế security của Spring, Nếu không có → tất cả API đều public
@EnableMethodSecurity // cho phép dùng preAuthorize, postAuthorize
@RequiredArgsConstructor
public class SecurityConfig {
    private final String[] AUTH_ENDPOINTS = {"/nhaxe/auth/login", "/nhaxe/auth/logout", "/auth/refresh-token",
        "/nhaxe/auth/register", "/auth/send-otp", "/auth/verify-otp", "/auth/logout", "/register/init",
            "/register/verify", "/auth/log-out", "/admin/auth/login"};
    private final String[] PUBLIC_ENDPOINTS = {"/provinces", "/stops", "/bus-type/**", "/bus-type"};
    private final String[] PUBLIC_POST_ENDPOINTS = {"/bus-type", "/momo/**", "/api/**", "/admin/create"};
    private final String[] ADMIN_ENDPOINTS = {"/users", "/admin/company-page", "/admin/company-register-page",
        "/admin/company-status"};
    private final String[] MANAGER_ENDPOINTS = {"/nhaxe/member", "/nhaxe/routes", "/nhaxe/trips", "/nhaxe/trips/open",
        "/nhaxe/report"};
    private final String[] COMPANY_VIEW_ENDPOINTS = {"/nhaxe/trips", "/nhaxe/routes", "/nhaxe/bus-company"};
    private final String[] COMPANY_UPDATE_ENDPOINTS = {"/nhaxe/orders/hold-seats",
            "/nhaxe/orders/unhold-seats", "/nhaxe/orders/book-order", "/auth/change-password"};
    private final String[] CUSTOMER_ENDPOINTS = {"/trips/search", "/trips/stops", "/trips/bus-diagram"};
    private final String[] CUSTOMER_POST_ENDPOINTS = {"/customer/orders/hold-seats/**", "/customer/orders/payment/**"};
    private final String[] CUSTOMER_GET_ENDPOINTS = {"/customer/orders/payment-status"};

    @Autowired
    private CustomJwtDecoder customJwtDecoder;
    @Autowired
    private JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;
    @Autowired
    private CustomJwtAuthenticationConverter customJwtAuthenticationConverter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity httpSecurity){
        httpSecurity.cors(Customizer.withDefaults()); // Bật CORS
        httpSecurity.authorizeHttpRequests(request ->
                request.requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        // Browser gửi OPTIONS trước (CORS)
                        .requestMatchers(HttpMethod.GET, CUSTOMER_ENDPOINTS).permitAll()
                        .requestMatchers(HttpMethod.POST, CUSTOMER_POST_ENDPOINTS).hasRole(RoleEnum.CUSTOMER.name())
                        .requestMatchers(HttpMethod.GET, CUSTOMER_GET_ENDPOINTS).hasRole(RoleEnum.CUSTOMER.name())
                        .requestMatchers(HttpMethod.POST, AUTH_ENDPOINTS).permitAll()
                        .requestMatchers(HttpMethod.GET, PUBLIC_ENDPOINTS).permitAll()
                        .requestMatchers(HttpMethod.POST, PUBLIC_POST_ENDPOINTS).permitAll()
                        .requestMatchers(HttpMethod.GET, MANAGER_ENDPOINTS).hasRole(RoleEnum.MANAGER.name())
                        .requestMatchers(HttpMethod.POST, MANAGER_ENDPOINTS).hasRole(RoleEnum.MANAGER.name())
                        .requestMatchers(HttpMethod.PUT, MANAGER_ENDPOINTS).hasRole(RoleEnum.MANAGER.name())
                        .requestMatchers(HttpMethod.GET, COMPANY_VIEW_ENDPOINTS)
                            .hasAnyRole(RoleEnum.MANAGER.name(), RoleEnum.STAFF.name())
                        .requestMatchers(HttpMethod.POST, COMPANY_UPDATE_ENDPOINTS)
                            .hasAnyRole(RoleEnum.MANAGER.name(), RoleEnum.STAFF.name())
                        .requestMatchers(HttpMethod.PUT, ADMIN_ENDPOINTS).hasRole(RoleEnum.ADMIN.name())
                        .anyRequest().authenticated()
                        //Tất cả API khác → bắt buộc có JWT
        );
        httpSecurity.oauth2ResourceServer(oAuth2 ->
                oAuth2.jwt(jwtConfigurer ->
                                jwtConfigurer.decoder(customJwtDecoder)
                                        .jwtAuthenticationConverter(customJwtAuthenticationConverter)
//                                        .jwtAuthenticationConverter(jwtAuthenticationConverter())

                        )
                        .authenticationEntryPoint(jwtAuthenticationEntryPoint)
        );

        httpSecurity.csrf(AbstractHttpConfigurer::disable);
        return httpSecurity.build();
    }
    @Bean
    public JwtAuthenticationConverter jwtAuthenticationConverter(){
        JwtGrantedAuthoritiesConverter jwtGrantedAuthoritiesConverter = new JwtGrantedAuthoritiesConverter();
//        jwtGrantedAuthoritiesConverter.setAuthoritiesClaimName("role");
        jwtGrantedAuthoritiesConverter.setAuthorityPrefix("ROLE_");

        JwtAuthenticationConverter jwtAuthenticationConverter = new JwtAuthenticationConverter();
        jwtAuthenticationConverter.setJwtGrantedAuthoritiesConverter(jwtGrantedAuthoritiesConverter);
        return jwtAuthenticationConverter;
    }
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        // Cách mới trong Spring Boot 3
        configuration.addAllowedOrigin("http://localhost:5173"); // FE
        configuration.addAllowedMethod("GET");
        configuration.addAllowedMethod("POST");
        configuration.addAllowedMethod("PUT");
        configuration.addAllowedMethod("DELETE");
        configuration.addAllowedMethod("OPTIONS");
        configuration.addAllowedHeader("Authorization");
        configuration.addAllowedHeader("Content-Type");
        configuration.setExposedHeaders(java.util.List.of("Authorization"));
        configuration.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
