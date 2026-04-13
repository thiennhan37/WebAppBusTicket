package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.request.CompanyRegisterRequest;
import com.example.BusTicket.entity.CompanyRegister;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-04-12T23:07:46+0700",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 24.0.2 (Oracle Corporation)"
)
@Component
public class CompanyRegisterMapperImpl implements CompanyRegisterMapper {

    @Override
    public CompanyRegister toCompanyRegister(CompanyRegisterRequest request) {
        if ( request == null ) {
            return null;
        }

        CompanyRegister.CompanyRegisterBuilder companyRegister = CompanyRegister.builder();

        companyRegister.hostName( request.getHostName() );
        companyRegister.companyName( request.getCompanyName() );
        companyRegister.hotline( request.getHotline() );
        companyRegister.email( request.getEmail() );

        return companyRegister.build();
    }
}
