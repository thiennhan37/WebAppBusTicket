package com.example.BusTicket.service;

import com.example.BusTicket.dto.request.CompanyRegisterRequest;
import com.example.BusTicket.dto.request.CompanyUpRequest;
import com.example.BusTicket.entity.Admin;
import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.CompanyRegister;
import com.example.BusTicket.enums.RegisterType;
import com.example.BusTicket.enums.StatusEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.CompanyRegisterMapper;
import com.example.BusTicket.repository.jpa.AdminRepository;
import com.example.BusTicket.repository.jpa.BusCompanyRepository;
import com.example.BusTicket.repository.jpa.CompanyRegisterRepository;
import com.example.BusTicket.specification.BusCompanySpecification;
import com.example.BusTicket.specification.CompanyRegisterSpecification;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;


import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AdminService {
    private final AdminRepository adminRepository;
    private final PasswordEncoder passwordEncoder;
    private final BusCompanyRepository busCompanyRepository;
    private final CompanyRegisterMapper companyRegisterMapper;
    private final CompanyRegisterRepository companyRegisterRepository;

    public Admin createAdmin(Map<String, String> request){
        if(adminRepository.existsByEmail(request.get("email"))) throw new MyAppException(ErrorCode.EMAIL_EXISTED);

        Admin admin = Admin.builder()
                .id(UUID.randomUUID().toString())
                .createdAt(LocalDateTime.now())
                .dob(LocalDate.now())
                .email(request.get("email"))
                .password(passwordEncoder.encode(request.get("password")))
                .phone(request.get("phone"))
                .fullName(request.get("fullName"))
                .gender(request.get("gender"))
                .status(StatusEnum.ACTIVE.name())
                .build();
        adminRepository.save(admin);
        return admin;

    }

    public Page<BusCompany> getCompanyPage(String keyword, String status, Pageable pageable){
        Specification<BusCompany> specification = Specification
                .where(BusCompanySpecification.containsKeyword(keyword))
                .and(BusCompanySpecification.hasStatus(status));
        Pageable fixedPageable = PageRequest.of(pageable.getPageNumber(), 5, pageable.getSort());
        Page<BusCompany> busCompanyPage = busCompanyRepository.findAll(specification, fixedPageable);
        return busCompanyPage;
    }
    public void  updateStatus(String busCompanyId, CompanyUpRequest request){
        String status = request.getStatus();
        BusCompany busCompany = busCompanyRepository.findById(busCompanyId)
                .orElseThrow(() -> new MyAppException(ErrorCode.COMPANY_NOT_EXISTED));
        if(!status.equals(StatusEnum.ACTIVE.name()) && !status.equals(StatusEnum.BLOCKED.name()))
            throw new MyAppException(ErrorCode.INVALID_PARAMETER);
        busCompany.setStatus(status);
        busCompanyRepository.save(busCompany);
    }

    public Page<CompanyRegister> getCompanyRegisterPage
            (String keyword, String reviewedName, String status, Pageable pageable){

        Specification<CompanyRegister> specification = Specification
                .where(CompanyRegisterSpecification.containsKeyword(keyword))
                .and(CompanyRegisterSpecification.hasStatus(status))
                .and(CompanyRegisterSpecification.hasReviewedName(reviewedName));
        Pageable fixedPageable = PageRequest.of(pageable.getPageNumber(), 5, pageable.getSort());
        Page<CompanyRegister> companyRegisterPage = companyRegisterRepository.findAll(specification, fixedPageable);
        return companyRegisterPage;
    }
    public void acceptCompanyRegister(CompanyRegister request){
        CompanyRegister companyRegister = companyRegisterRepository.findById(request.getId())
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        companyRegister.setStatus(RegisterType.ACCEPTED.name());
        companyRegister.setUpdatedAt(LocalDateTime.now());
        BusCompany busCompany = companyRegisterMapper.toBusCompany(companyRegister);
        busCompany.setCreatedAt(LocalDateTime.now());
        companyRegisterRepository.save(companyRegister);
        busCompanyRepository.save(busCompany);
    }
    public void rejectCompanyRegister(CompanyRegister request){
        CompanyRegister companyRegister = companyRegisterRepository.findById(request.getId())
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        companyRegister.setStatus(RegisterType.REJECTED.name());
        companyRegister.setUpdatedAt(LocalDateTime.now());
        companyRegisterRepository.save(companyRegister);
    }


}
