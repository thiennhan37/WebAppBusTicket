package com.example.BusTicket.service;

import com.example.BusTicket.dto.request.CompanyUpRequest;
import com.example.BusTicket.dto.response.report.RevenueReportResp;
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
public class AdminReportService {
    private final AdminRepository adminRepository;
    private final PasswordEncoder passwordEncoder;
    private final BusCompanyRepository busCompanyRepository;
    private final CompanyRegisterMapper companyRegisterMapper;
    private final CompanyRegisterRepository companyRegisterRepository;

//    public RevenueReportResp getRevenueReportResp(){
//
//    }


}
