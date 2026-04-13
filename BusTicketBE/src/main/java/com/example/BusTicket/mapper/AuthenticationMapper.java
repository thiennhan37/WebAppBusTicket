package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.request.CompanyRegisterRequest;
import com.example.BusTicket.dto.response.AuthenticationResponse;
import com.example.BusTicket.dto.response.LogoutResponse;
import com.example.BusTicket.entity.CompanyRegister;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface AuthenticationMapper {
    LogoutResponse toLogoutResponse(AuthenticationResponse response);
}
