package com.example.BusTicket.service;

import com.example.BusTicket.dto.request.CompanyUserCrRequest;
import com.example.BusTicket.dto.response.CompanyUserResponse;
import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.CompanyUser;
import com.example.BusTicket.enums.StatusEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.CompanyUserMapper;
import com.example.BusTicket.repository.jpa.BusCompanyRepository;
import com.example.BusTicket.repository.jpa.CompanyUserRepository;
import com.example.BusTicket.util.IdUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class CompanyUserService {
    private final CompanyUserRepository companyUserRepository;
    private final BusCompanyRepository busCompanyRepository;
    private final CompanyUserMapper companyUserMapper;
    private final PasswordEncoder passwordEncoder;

    public List<CompanyUserResponse> getCompanyUserList(){
        List<CompanyUser> companyUserList = companyUserRepository.findAll();
        System.out.println(companyUserList);
        List<CompanyUserResponse> companyUserResponseList = companyUserMapper.toCompanyUserResponseList(companyUserList);
        System.out.println(companyUserResponseList);
        return companyUserResponseList;
    }

    public CompanyUserResponse createCompanyUser(CompanyUserCrRequest request){
        String companyId = request.getBusCompanyId();
        if(!busCompanyRepository.existsById(companyId)){
            throw new MyAppException(ErrorCode.COMPANY_NOT_EXISTED);
        }
        if(companyUserRepository.existsByEmail(request.getEmail())){
            throw new MyAppException(ErrorCode.EMAIL_EXISTED);
        }

        CompanyUser companyUser = companyUserMapper.toCompanyUser(request);
        companyUser.setId(IdUtil.generateID());
        companyUser.setPassword(passwordEncoder.encode(companyUser.getPassword()));
        companyUser.setBusCompany(BusCompany.builder().id(request.getBusCompanyId()).build());
        companyUser.setStatus(StatusEnum.ACTIVE.name());
        companyUser.setCreatedAt(LocalDateTime.now());

        companyUserRepository.save(companyUser);
        return companyUserMapper.toCompanyUserResponse(companyUser);
    }
}
