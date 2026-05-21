package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.CompanyRegisterRequest;
import com.example.BusTicket.dto.request.CompanyUpRequest;
import com.example.BusTicket.dto.request.CompanyUserCrRequest;
import com.example.BusTicket.dto.request.StatusUpRequest;
import com.example.BusTicket.dto.response.CompanyUserResponse;
import com.example.BusTicket.dto.response.CustomerInfoResponse;
import com.example.BusTicket.entity.*;
import com.example.BusTicket.enums.GenderEnum;
import com.example.BusTicket.enums.RegisterType;
import com.example.BusTicket.enums.RoleEnum;
import com.example.BusTicket.enums.StatusEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.CompanyRegisterMapper;
import com.example.BusTicket.mapper.CompanyUserMapper;
import com.example.BusTicket.mapper.CustomerMapper;
import com.example.BusTicket.repository.jpa.*;
import com.example.BusTicket.specification.BusCompanySpecification;
import com.example.BusTicket.specification.CompanyRegisterSpecification;
import com.example.BusTicket.specification.CompanyUserSpecification;
import com.example.BusTicket.specification.CustomerSpecification;
import com.example.BusTicket.util.IdUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.IdGenerator;
import org.springframework.web.bind.annotation.RequestParam;


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
    private final CompanyUserRepository companyUserRepository;
    private final CompanyUserMapper companyUserMapper;
    private final CustomerRepository customerRepository;
    private final CustomerMapper customerMapper;
    private final SendMailService sendMailService;

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

    public BusCompany getCompanyInfo(String busCompanyId){
        BusCompany busCompany = busCompanyRepository.findById(busCompanyId)
                .orElseThrow(() -> new MyAppException(ErrorCode.COMPANY_NOT_EXISTED));
        return busCompany;
    }
    public Page<BusCompany> getCompanyPage(String keyword, String status, Pageable pageable){
        Specification<BusCompany> specification = Specification
                .where(BusCompanySpecification.containsKeyword(keyword))
                .and(BusCompanySpecification.hasStatus(status));
        Pageable fixedPageable = PageRequest.of(pageable.getPageNumber(), 5, pageable.getSort());
        Page<BusCompany> busCompanyPage = busCompanyRepository.findAll(specification, fixedPageable);
        return busCompanyPage;
    }
    public void  updateCompanyStatus(String busCompanyId, StatusUpRequest request){
        String status = request.getStatus();
        BusCompany busCompany = busCompanyRepository.findById(busCompanyId)
                .orElseThrow(() -> new MyAppException(ErrorCode.COMPANY_NOT_EXISTED));
        if(!status.equals(StatusEnum.ACTIVE.name()) && !status.equals(StatusEnum.BLOCKED.name()))
            throw new MyAppException(ErrorCode.INVALID_PARAMETER);
        busCompany.setStatus(status);
        busCompanyRepository.save(busCompany);
    }
    public void  updateCustomerStatus(String customerId, StatusUpRequest request){
        String status = request.getStatus();
        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        if(!status.equals(StatusEnum.ACTIVE.name()) && !status.equals(StatusEnum.BLOCKED.name()))
            throw new MyAppException(ErrorCode.INVALID_PARAMETER);
        StatusEnum statusEnum;
        if(status.equals(StatusEnum.ACTIVE.name())) statusEnum = StatusEnum.ACTIVE;
        else statusEnum = StatusEnum.BLOCKED;
        customer.setStatus(statusEnum);
        customerRepository.save(customer);
    }
    public void  updateStaffStatus(String staffId, StatusUpRequest request){
        String status = request.getStatus();
        CompanyUser companyUser = companyUserRepository.findById(staffId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        if(!status.equals(StatusEnum.ACTIVE.name()) && !status.equals(StatusEnum.BLOCKED.name()))
            throw new MyAppException(ErrorCode.INVALID_PARAMETER);
        companyUser.setStatus(status);
        companyUserRepository.save(companyUser);
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

    @Transactional
    public void acceptCompanyRegister(String CompanyRegisterId){
        Jwt jwt  = JwtHelper.getJwt();
        Admin reviewedAdmin = adminRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        CompanyRegister companyRegister = companyRegisterRepository.findById(CompanyRegisterId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        companyRegister.setReviewedBy(reviewedAdmin);
        companyRegister.setStatus(RegisterType.ACCEPTED.name());
        companyRegister.setUpdatedAt(LocalDateTime.now());
        BusCompany busCompany = companyRegisterMapper.toBusCompany(companyRegister);
        busCompany.setId(IdUtil.generateID());
        busCompany.setStatus(StatusEnum.ACTIVE.name());
        busCompany.setCreatedAt(LocalDateTime.now());

        busCompanyRepository.save(busCompany);
        String password = UUID.randomUUID().toString().substring(0, 8);
        CompanyUser companyUser = CompanyUser.builder()
                .id(IdUtil.generateID())
                .busCompany(busCompany)
                .role(RoleEnum.MANAGER.name())
                .phone(busCompany.getHotline())
                .email(busCompany.getEmail())
                .password(passwordEncoder.encode(password))
                .gender(GenderEnum.OTHER.name())
                .createdAt(LocalDateTime.now())
                .fullName(busCompany.getHostName())
                .status(StatusEnum.ACTIVE.name())
                .build();
        companyUserRepository.save(companyUser);

        companyRegisterRepository.save(companyRegister);
        sendMailService
                .sendCompanyAccountCreatedEmail(busCompany.getEmail(), busCompany.getCompanyName(),
                        busCompany.getEmail(), password);
    }
    @Transactional
    public void rejectCompanyRegister(String CompanyRegisterId){
        Jwt jwt  = JwtHelper.getJwt();
        Admin reviewedAdmin = adminRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        CompanyRegister companyRegister = companyRegisterRepository.findById(CompanyRegisterId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        companyRegister.setReviewedBy(reviewedAdmin);
        companyRegister.setStatus(RegisterType.REJECTED.name());
        companyRegister.setUpdatedAt(LocalDateTime.now());
        companyRegisterRepository.save(companyRegister);
        sendMailService.sendRegistrationRejectedEmail(companyRegister.getEmail(), companyRegister.getCompanyName());
    }

    public Page<CompanyUserResponse> getCompanyUserPage(String keyword, String status, Pageable pageable){
        Specification specification = Specification.where(CompanyUserSpecification.hasStatus(status))
                .and(CompanyUserSpecification.containsKeyword(keyword));
        Pageable fixedPageable = PageRequest.of(pageable.getPageNumber(), 5, pageable.getSort());
        Page<CompanyUser> companyUserPage = companyUserRepository.findAll(specification, fixedPageable);
        return companyUserPage.map(companyUserMapper::toCompanyUserResponse);
    }
    public Page<CustomerInfoResponse> getCustomerPage(String keyword, String status, Pageable pageable){
        Specification specification = Specification.where(CustomerSpecification.hasStatus(status))
                .and(CustomerSpecification.containsKeyword(keyword));
        Pageable fixedPageable = PageRequest.of(pageable.getPageNumber(), 5, pageable.getSort());
        Page<Customer> companyUserPage = customerRepository.findAll(specification, pageable);
        return companyUserPage.map(customerMapper::toCustomerInfoResponse);
    }

}
