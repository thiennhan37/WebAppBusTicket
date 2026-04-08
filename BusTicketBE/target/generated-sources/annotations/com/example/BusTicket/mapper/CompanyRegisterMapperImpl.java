package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.request.CompanyRegisterRequest;
import com.example.BusTicket.entity.CompanyRegister;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-04-08T14:32:29+0700",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 24.0.2 (Oracle Corporation)"
)
@Component
public class CompanyRegisterMapperImpl implements CompanyRegisterMapper {

    @Override
    public CompanyRegister toCompanyRegister(CompanyRegisterRequest request) {
        if ( request == null ) {
            return null;
        }

        CompanyRegister companyRegister = new CompanyRegister();

        companyRegister.setName( request.getName() );
        companyRegister.setHotline( request.getHotline() );
        companyRegister.setEmail( request.getEmail() );
        companyRegister.setCreatedAt( request.getCreatedAt() );

        return companyRegister;
    }
}
