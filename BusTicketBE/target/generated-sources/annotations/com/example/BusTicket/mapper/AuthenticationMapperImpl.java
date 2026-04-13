package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.AuthenticationResponse;
import com.example.BusTicket.dto.response.LogoutResponse;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-04-13T14:59:30+0700",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 24.0.2 (Oracle Corporation)"
)
@Component
public class AuthenticationMapperImpl implements AuthenticationMapper {

    @Override
    public LogoutResponse toLogoutResponse(AuthenticationResponse response) {
        if ( response == null ) {
            return null;
        }

        LogoutResponse.LogoutResponseBuilder logoutResponse = LogoutResponse.builder();

        logoutResponse.user( response.getUser() );
        logoutResponse.company( response.getCompany() );
        logoutResponse.accessToken( response.getAccessToken() );

        return logoutResponse.build();
    }
}
