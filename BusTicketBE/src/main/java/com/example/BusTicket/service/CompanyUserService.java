package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.CompanyUserCrRequest;
import com.example.BusTicket.dto.request.CompanyUserUpRequest;
import com.example.BusTicket.dto.response.CompanyUserResponse;
import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.CompanyUser;
import com.example.BusTicket.enums.StatusEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.CompanyUserMapper;
import com.example.BusTicket.repository.jpa.BusCompanyRepository;
import com.example.BusTicket.repository.jpa.CompanyUserRepository;
import com.example.BusTicket.specification.CompanyUserSpecification;
import com.example.BusTicket.util.IdUtil;
import com.nimbusds.jose.JOSEException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import java.text.ParseException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class CompanyUserService {
    private final CompanyUserRepository companyUserRepository;
    private final BusCompanyRepository busCompanyRepository;
    private final CompanyUserMapper companyUserMapper;
    private final PasswordEncoder passwordEncoder;
    private final SendMailService accountMailService;
    private final JwtService jwtService;


    public Page<CompanyUserResponse> getAllCompanyUser(String status, String role, String keyword, Pageable pageable){
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        Jwt jwt = (Jwt) auth.getPrincipal();
        CompanyUser manager =  companyUserRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));

        String busCompanyId = manager.getBusCompany().getId();
        Specification<CompanyUser> spec = Specification.where(CompanyUserSpecification.hasStatus(status))
                .and(CompanyUserSpecification.hasRole(role))
                .and(CompanyUserSpecification.hasBusCompanyId(busCompanyId))
                .and(CompanyUserSpecification.containsKeyword(keyword));
        Pageable fixedPageable = PageRequest.of(pageable.getPageNumber(), 5);
        Page<CompanyUser> page = companyUserRepository.findAll(spec, fixedPageable);
        return page.map(companyUserMapper::toCompanyUserResponse);
    }

    public CompanyUserResponse createCompanyUser(CompanyUserCrRequest request){
        Jwt jwt = JwtHelper.getJwt();
        String id = jwt.getSubject();
        CompanyUser manager = companyUserRepository.findById(id)
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        String companyId = request.getBusCompanyId();
        BusCompany busCompany = busCompanyRepository.findById(companyId)
                .orElseThrow(() -> new MyAppException(ErrorCode.COMPANY_NOT_EXISTED));
        if( !manager.getBusCompany().getId().equals(busCompany.getId()))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);
        if(companyUserRepository.existsByEmail(request.getEmail()))
            throw new MyAppException(ErrorCode.EMAIL_EXISTED);

        CompanyUser companyUser = companyUserMapper.toCompanyUser(request);
        companyUser.setId(IdUtil.generateID());
        String password = UUID.randomUUID().toString().substring(0, 8);
        companyUser.setPassword(passwordEncoder.encode(password));
        companyUser.setBusCompany(busCompany);
        companyUser.setStatus(StatusEnum.ACTIVE.name());
        companyUser.setCreatedAt(LocalDateTime.now());

        companyUserRepository.save(companyUser);
        accountMailService.sendCredentials(companyUser.getEmail(), password, busCompany.getCompanyName());
        return companyUserMapper.toCompanyUserResponse(companyUser);
    }
    public CompanyUserResponse updateCompanyUser(CompanyUserUpRequest request)
            throws ParseException, JOSEException {
        String busCompanyId = request.getBusCompanyId();
        Jwt jwt = JwtHelper.getJwt();
        String id = jwt.getSubject();
        CompanyUser manager = companyUserRepository.findById(id)
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        if(!manager.getBusCompany().getId().equals(busCompanyId)) throw new MyAppException(ErrorCode.ACCESS_DENIED);

        CompanyUser staff = companyUserRepository.findById(request.getId())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        if(staff.getRole().equals("MANAGER")) throw new MyAppException(ErrorCode.ACCESS_DENIED);
        String fullName = request.getFullName();
        if(fullName != null && !fullName.isBlank()) staff.setFullName(fullName);
        String phone = request.getPhone();
        if(phone != null && !phone.isBlank()) staff.setPhone(phone);
        String gender = request.getGender();
        if(gender != null && !gender.isBlank()) staff.setGender(gender);
        LocalDate dob = request.getDob();
        if(dob != null) staff.setDob(dob);
        String status = request.getStatus();
        if(status != null && (status.equals(StatusEnum.ACTIVE.name()) || status.equals(StatusEnum.BLOCKED.name())) )
            staff.setStatus(status);

        companyUserRepository.save(staff);
        return companyUserMapper.toCompanyUserResponse(staff);
    }

}
