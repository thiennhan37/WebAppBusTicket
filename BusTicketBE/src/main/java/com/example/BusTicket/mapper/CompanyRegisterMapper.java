package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.request.CompanyRegisterRequest;
import com.example.BusTicket.dto.request.CompanyUserCrRequest;
import com.example.BusTicket.dto.response.CompanyUserResponse;
import com.example.BusTicket.entity.CompanyRegister;
import com.example.BusTicket.entity.CompanyUser;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring")
public interface CompanyRegisterMapper {
    CompanyRegister toCompanyRegister(CompanyRegisterRequest request);
}
