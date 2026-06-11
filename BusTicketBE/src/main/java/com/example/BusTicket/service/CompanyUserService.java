package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.CompanyUserCrRequest;
import com.example.BusTicket.dto.request.CompanyUserUpRequest;
import com.example.BusTicket.dto.response.CompanyUserResponse;
import com.example.BusTicket.dto.response.CustomResponse;
import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.CompanyUser;
import com.example.BusTicket.enums.GenderEnum;
import com.example.BusTicket.enums.RoleEnum;
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
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.text.ParseException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

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
        String password = request.getPassword() != null ? request.getPassword() : UUID.randomUUID().toString().substring(0, 8);
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
        if(staff.getRole().equals("MANAGER") && !staff.getId().equals(id)) throw new MyAppException(ErrorCode.ACCESS_DENIED);
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
    public CompanyUserResponse getMe(){
        Jwt jwt = JwtHelper.getJwt();
        String role = jwt.getClaimAsString("ROLE");
        String id = jwt.getSubject();
        CompanyUser companyUser = companyUserRepository.findById(id)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        return companyUserMapper.toCompanyUserResponse(companyUser);
    }

    @Transactional
    public CustomResponse importListCompanyUser(MultipartFile file){
        Jwt jwt = JwtHelper.getJwt();
        CompanyUser manager = companyUserRepository.findById(jwt.getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        BusCompany busCompany = manager.getBusCompany();
        Set<String> emailInFile = new HashSet<>();
        List<CompanyUser> companyUserList = new ArrayList<>();
        List<String> passwordList = new ArrayList<>();
        try (Workbook workbook = new XSSFWorkbook(file.getInputStream())) {

            Sheet sheet = workbook.getSheetAt(0);
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                String fullName = row.getCell(1).getStringCellValue();
                String email = row.getCell(2).getStringCellValue();
                if(emailInFile.contains(email))
                    return CustomResponse.builder()
                            .message(ErrorCode.EMAIL_EXISTED_IN_FILE.getMessage()).line(i)
                            .build();
                emailInFile.add(email);

                String phone = row.getCell(3).getStringCellValue();

                String role = row.getCell(4).getStringCellValue();
                if(!role.equals(RoleEnum.MANAGER.name()) && !role.equals(RoleEnum.STAFF.name()))
                    return CustomResponse.builder()
                            .message(ErrorCode.INVALID_PARAMETER.getMessage()).line(i)
                            .build();

                String gender = row.getCell(5).getStringCellValue();
                if(!gender.equals(GenderEnum.MALE.name())
                        && !gender.equals(GenderEnum.FEMALE.name())
                        && !gender.equals(GenderEnum.OTHER.name()))
                    return CustomResponse.builder()
                            .message(ErrorCode.INVALID_PARAMETER.getMessage()).line(i)
                            .build();
                LocalDate dob = row.getCell(6).getLocalDateTimeCellValue().toLocalDate();
                String password = UUID.randomUUID().toString().substring(0, 8);
                passwordList.add(password);
                CompanyUser staff = CompanyUser.builder()
                        .id(IdUtil.generateID())
                        .fullName(fullName)
                        .phone(phone)
                        .busCompany(busCompany)
                        .role(role)
                        .createdAt(LocalDateTime.now())
                        .email(email)
                        .gender(gender)
                        .dob(dob)
                        .password(passwordEncoder.encode(password))
                        .status(StatusEnum.ACTIVE.name())
                        .build();
                companyUserList.add(staff);
            }
            List<String> duplicatedEmailList = companyUserRepository.existByEmailInList(emailInFile);
            for(int i = 0; i < companyUserList.size(); i++){
                if(duplicatedEmailList.contains(companyUserList.get(i).getEmail()))
                    return CustomResponse.builder()
                            .message(ErrorCode.EMAIL_EXISTED.getMessage()).line(i + 1)
                            .build();
            }
            companyUserRepository.saveAll(companyUserList);
            for(int i = 0; i < companyUserList.size(); i++){
                accountMailService.sendCredentials(companyUserList.get(i).getEmail(),
                       passwordList.get(i), busCompany.getCompanyName());
            }


            return CustomResponse.builder().line(0).build();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
