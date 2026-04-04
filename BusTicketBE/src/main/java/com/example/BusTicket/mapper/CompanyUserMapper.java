package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.request.CompanyUserCrRequest;
import com.example.BusTicket.dto.response.CompanyUserResponse;
import com.example.BusTicket.entity.CompanyUser;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring")
public interface CompanyUserMapper {
    @Mapping(target = "busCompanyId", source = "busCompany.id")
    CompanyUserResponse toCompanyUserResponse(CompanyUser companyUser);
    List<CompanyUserResponse> toCompanyUserResponseList(List<CompanyUser> companyUserList);
    @Mapping(target = "busCompany", ignore = true)
    CompanyUser toCompanyUser(CompanyUserCrRequest request);
}
