package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.request.CompanyUpRequest;
import com.example.BusTicket.dto.response.BusCompanyResponse;
import com.example.BusTicket.dto.response.CompanyRatingResponse;
import com.example.BusTicket.dto.response.CustomerInfoResponse;
import com.example.BusTicket.dto.response.DetailRatingResponse;
import com.example.BusTicket.entity.*;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.BusCompanyMapper;
import com.example.BusTicket.mapper.CustomerMapper;
import com.example.BusTicket.repository.jpa.*;
import com.example.BusTicket.specification.BusCompanySpecification;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;


import java.util.List;

@Service
@RequiredArgsConstructor
public class BusCompanyService {
    private final CompanyUserRepository companyUserRepository;
    private final BusCompanyRepository busCompanyRepository;
    private final BusCompanyMapper busCompanyMapper;
    private final S3Service s3Service;
    private final CustomerMapper customerMapper;


    public BusCompany getBusCompany(String busCompanyId) {
        Jwt jwt = JwtHelper.getJwt();
        CompanyUser companyUser = checkPermission(jwt.getSubject(), busCompanyId);
        return companyUser.getBusCompany();
    }

    public BusCompany updateBusCompany(String busCompanyId, CompanyUpRequest request) {
        Jwt jwt = JwtHelper.getJwt();
        CompanyUser companyUser = checkPermission(jwt.getSubject(), busCompanyId);
        BusCompany busCompany = companyUser.getBusCompany();
        if(request.getPolicy() != null && !request.getPolicy().isBlank()) busCompany.setPolicy(request.getPolicy());
        if(request.getAvatarFile() != null){
            try{
                String avatarUrl = s3Service.uploadFile(request.getAvatarFile());
                busCompany.setAvatarUrl(avatarUrl);
            }catch (Exception e){
                throw new MyAppException(ErrorCode.ERROR_S3);
            }
        }
        busCompanyRepository.save(busCompany);
        return busCompany;
    }
    private CompanyUser checkPermission(String companyUserId, String busCompanyId){
        CompanyUser companyUser = companyUserRepository.findById(companyUserId)
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = busCompanyRepository.findById(busCompanyId)
                .orElseThrow(() -> new MyAppException(ErrorCode.COMPANY_NOT_EXISTED));
        if( !companyUser.getBusCompany().getId().equals(busCompanyId))
            throw new MyAppException(ErrorCode.ACCESS_DENIED);
        return companyUser;
    }
    public CompanyRatingResponse getCompanyRatingResponse(){
        Jwt jwt = JwtHelper.getJwt();
        String companyUserId = jwt.getSubject();
        CompanyUser companyUser = companyUserRepository.findById(companyUserId)
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = companyUser.getBusCompany();
        List<Object[]> object = busCompanyRepository.getCompanyRating(busCompany.getId());
        Object[] firstRow = object.getFirst();
        CompanyRatingResponse response = CompanyRatingResponse.builder().build();

        Double serviceQualityAvg = firstRow[0] == null ? 0.0 : Math.round(Double.parseDouble(firstRow[0].toString()) * 10.0) / 10.0;
        Double punctualityAvg = firstRow[1] == null ? 0.0 : Math.round(Double.parseDouble(firstRow[1].toString()) * 10.0) / 10.0;
        Double cleanlinessAvg = firstRow[2] == null ? 0.0 : Math.round(Double.parseDouble(firstRow[2].toString()) * 10.0) / 10.0;
        Double safetyAvg = firstRow[3] == null ? 0.0 : Math.round(Double.parseDouble(firstRow[3].toString()) * 10.0) / 10.0;
        Double averageStars = (serviceQualityAvg + punctualityAvg + cleanlinessAvg + safetyAvg) / 4.0;
        Long ratingCount = Long.parseLong(firstRow[4].toString());

        return CompanyRatingResponse.builder()
                .serviceQualityAvg(serviceQualityAvg)
                .punctualityAvg(punctualityAvg)
                .cleanlinessAvg(cleanlinessAvg)
                .safetyAvg(safetyAvg)
                .averageStars(averageStars)
                .ratingCount(ratingCount)
                .build();
    }
    public Page<DetailRatingResponse> getDetailRatings(Integer avgStars, Pageable pageable){
        Jwt jwt = JwtHelper.getJwt();
        String companyUserId = jwt.getSubject();
        CompanyUser companyUser = companyUserRepository.findById(companyUserId)
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        BusCompany busCompany = companyUser.getBusCompany();

        Pageable fixedPageable = PageRequest.of(pageable.getPageNumber(), 3, pageable.getSort());
        Page<DetailRatingResponse> detailRatingResponses =
                busCompanyRepository.getDetailRatings(busCompany.getId(), avgStars, fixedPageable);
        return detailRatingResponses;
    }

    public Page<BusCompanyResponse> getCompanyForCustomerChat(String name, Pageable pageable) {
//        int size = pageable.getPageSize() > 0 ? pageable.getPageSize() : 10;
        int size = 10;
        Pageable fixedPageable = PageRequest.of(pageable.getPageNumber(), size);
        Specification<BusCompany> spec = BusCompanySpecification.containsKeyword(name);
        Page<BusCompany> busCompanyPage = busCompanyRepository.findAll(spec, fixedPageable);
        return busCompanyPage.map(busCompanyMapper::toBusCompanyResponse);
    }

    public List<CustomerInfoResponse> getCustomerForChat(String phone, Pageable pageable) {
//        int size = pageable.getPageSize() > 0 ? pageable.getPageSize() : 10;
        int size = 10;
        CompanyUser companyUser = companyUserRepository.findById(JwtHelper.getJwt().getSubject())
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        String busCompanyId = companyUser.getBusCompany().getId();
        Pageable fixedPageable = PageRequest.of(pageable.getPageNumber(), size);
        List<Customer> customerList = busCompanyRepository.getCustomerForChat(busCompanyId, phone, fixedPageable);
        return customerMapper.toCustomerInfoResponseList(customerList);
    }

    public List<BusCompanyResponse> getCompaniesWithHighRating(){
        List<Object[]> rawList = busCompanyRepository.getCompaniesWithHighRatingRaw();
        return rawList.stream().map(row -> {
            String id = row[0] != null ? row[0].toString() : null;
            String companyName = row[1] != null ? row[1].toString() : null;
            String avatarUrl = row[2] != null ? row[2].toString() : null;
            String email = row[3] != null ? row[3].toString() : null;
            String hotline = row[4] != null ? row[4].toString() : null;
            Double avgStars = row[5] != null ? Math.round(Double.parseDouble(row[5].toString()) * 10.0) / 10.0 : 0.0;
            Long ratingCount = row[6] != null ? Long.parseLong(row[6].toString()) : 0L;

            return BusCompanyResponse.builder()
                    .id(id)
                    .CompanyName(companyName)
                    .avatarUrl(avatarUrl)
                    .email(email)
                    .hotline(hotline)
                    .avgStars(avgStars)
                    .ratingCount(ratingCount)
                    .build();
        }).toList();
    }
}
