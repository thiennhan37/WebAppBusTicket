package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.AuthenticationResponse;
import com.example.BusTicket.dto.response.LoginResponse;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-04-27T18:24:02+0700",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 24.0.2 (Oracle Corporation)"
)
@Component
public class AuthenticationMapperImpl implements AuthenticationMapper {

    @Override
    public LoginResponse toLoginResponse(AuthenticationResponse response) {
        if ( response == null ) {
            return null;
        }

        LoginResponse.LoginResponseBuilder loginResponse = LoginResponse.builder();

        loginResponse.user( response.getUser() );
        loginResponse.company( response.getCompany() );
        loginResponse.accessToken( response.getAccessToken() );

        return loginResponse.build();
    }
}
