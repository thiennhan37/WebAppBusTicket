package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.request.CompanyUserCrRequest;
import com.example.BusTicket.dto.response.CompanyUserResponse;
import com.example.BusTicket.entity.CompanyUser;
import jakarta.validation.constraints.NotNull;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.springframework.data.domain.Page;

import java.util.List;

@Mapper(componentModel = "spring")
public interface CompanyUserMapper {
    @Mapping(target = "busCompanyId", source = "busCompany.id")
    CompanyUserResponse toCompanyUserResponse(CompanyUser companyUser);
    List<CompanyUserResponse> toCompanyUserResponseList(List<CompanyUser> companyUserList);
    @Mapping(target = "busCompany", ignore = true)
    CompanyUser toCompanyUser(CompanyUserCrRequest request);
}
