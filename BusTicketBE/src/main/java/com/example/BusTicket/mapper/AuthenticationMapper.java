package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.AuthenticationResponse;
import com.example.BusTicket.dto.response.LoginResponse;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface AuthenticationMapper {
    LoginResponse toLoginResponse(AuthenticationResponse response);
}
