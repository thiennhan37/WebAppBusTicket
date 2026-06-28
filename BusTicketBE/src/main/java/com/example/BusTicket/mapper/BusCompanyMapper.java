package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.request.CompanyUserCrRequest;
import com.example.BusTicket.dto.response.BusCompanyResponse;
import com.example.BusTicket.dto.response.CompanyUserResponse;
import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.CompanyUser;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring")
public interface BusCompanyMapper {
    @Mapping(source = "companyName", target = "CompanyName")
    @Mapping(target = "avgStars", ignore = true)
    @Mapping(target = "ratingCount", ignore = true)
    BusCompanyResponse toBusCompanyResponse(BusCompany busCompany);

}
