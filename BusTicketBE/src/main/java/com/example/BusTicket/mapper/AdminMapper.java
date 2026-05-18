package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.AdminResponse;
import com.example.BusTicket.dto.response.AuthenticationResponse;
import com.example.BusTicket.dto.response.LoginResponse;
import com.example.BusTicket.entity.Admin;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface AdminMapper {
    AdminResponse toAdminResponse(Admin admin);
}
