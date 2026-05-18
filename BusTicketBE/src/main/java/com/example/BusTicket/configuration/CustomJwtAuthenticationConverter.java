package com.example.BusTicket.configuration;

import com.example.BusTicket.dto.general.InfoAccount;
import com.example.BusTicket.enums.AccountType;
import com.example.BusTicket.enums.RoleEnum;
import com.example.BusTicket.enums.StatusEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.repository.jpa.AdminRepository;
import com.example.BusTicket.repository.jpa.CompanyUserRepository;
import com.example.BusTicket.repository.jpa.CustomerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.core.convert.converter.Converter;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class CustomJwtAuthenticationConverter implements Converter<Jwt, AbstractAuthenticationToken> {

    private final CompanyUserRepository companyUserRepository;
    private final AdminRepository adminRepository;
    private final CustomerRepository customerRepository;

    @Override
    public AbstractAuthenticationToken  convert(Jwt jwt) {
        String accountId = jwt.getSubject();
        String role = jwt.getClaimAsString("role");
        InfoAccount account = null;
        if(role.equals(RoleEnum.CUSTOMER.name())){
            account = customerRepository.findById(accountId).orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        }
        else if(role.equals(RoleEnum.ADMIN.name())){
            account = adminRepository.findById(accountId).orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        }
        else{
            account = companyUserRepository.findById(accountId).orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        }

        // check account locked
        if(account.getStatus().equals(StatusEnum.BLOCKED.name())) {
            throw new MyAppException(ErrorCode.ACCOUNT_BLOCKED);
        }

        List<SimpleGrantedAuthority> authorities =
                List.of(
                        new SimpleGrantedAuthority("ROLE_" + role)
                );

        return new JwtAuthenticationToken(jwt, authorities);
    }
}