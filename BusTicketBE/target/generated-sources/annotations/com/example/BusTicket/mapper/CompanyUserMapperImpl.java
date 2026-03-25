package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.request.CompanyUserCrRequest;
import com.example.BusTicket.dto.response.CompanyUserResponse;
import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.CompanyUser;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-03-25T20:45:59+0700",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 24.0.2 (Oracle Corporation)"
)
@Component
public class CompanyUserMapperImpl implements CompanyUserMapper {

    @Override
    public CompanyUserResponse toCompanyUserResponse(CompanyUser companyUser) {
        if ( companyUser == null ) {
            return null;
        }

        CompanyUserResponse.CompanyUserResponseBuilder companyUserResponse = CompanyUserResponse.builder();

        companyUserResponse.busCompanyId( companyUserBusCompanyId( companyUser ) );
        companyUserResponse.id( companyUser.getId() );
        companyUserResponse.email( companyUser.getEmail() );
        companyUserResponse.phone( companyUser.getPhone() );
        companyUserResponse.fullName( companyUser.getFullName() );
        companyUserResponse.dob( companyUser.getDob() );
        companyUserResponse.gender( companyUser.getGender() );
        companyUserResponse.role( companyUser.getRole() );
        companyUserResponse.status( companyUser.getStatus() );
        companyUserResponse.createdAt( companyUser.getCreatedAt() );

        return companyUserResponse.build();
    }

    @Override
    public List<CompanyUserResponse> toCompanyUserResponseList(List<CompanyUser> companyUserList) {
        if ( companyUserList == null ) {
            return null;
        }

        List<CompanyUserResponse> list = new ArrayList<CompanyUserResponse>( companyUserList.size() );
        for ( CompanyUser companyUser : companyUserList ) {
            list.add( toCompanyUserResponse( companyUser ) );
        }

        return list;
    }

    @Override
    public CompanyUser toCompanyUser(CompanyUserCrRequest request) {
        if ( request == null ) {
            return null;
        }

        CompanyUser companyUser = new CompanyUser();

        companyUser.setEmail( request.getEmail() );
        companyUser.setPhone( request.getPhone() );
        companyUser.setPassword( request.getPassword() );
        companyUser.setFullName( request.getFullName() );
        companyUser.setDob( request.getDob() );
        companyUser.setGender( request.getGender() );
        companyUser.setRole( request.getRole() );

        return companyUser;
    }

    private String companyUserBusCompanyId(CompanyUser companyUser) {
        if ( companyUser == null ) {
            return null;
        }
        BusCompany busCompany = companyUser.getBusCompany();
        if ( busCompany == null ) {
            return null;
        }
        String id = busCompany.getId();
        if ( id == null ) {
            return null;
        }
        return id;
    }
}
