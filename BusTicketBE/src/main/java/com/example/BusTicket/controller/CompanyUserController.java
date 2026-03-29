package com.example.BusTicket.controller;


import com.example.BusTicket.dto.request.CompanyUserCrRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.CompanyUserResponse;
import com.example.BusTicket.service.CompanyUserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PagedModel;
import org.springframework.security.core.parameters.P;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/nhaxe")
@RequiredArgsConstructor
@Slf4j
public class CompanyUserController {
    private final CompanyUserService companyUserService;
    @GetMapping("/member")
    ApiResponse<PagedModel<CompanyUserResponse>> getAllCompanyUser(String status, String role, Pageable pageable){

//        var authenticate = SecurityContextHolder.getContext().getAuthentication();
//        log.info("username : {}", authenticate.getName());
//        authenticate.getAuthorities().forEach(x -> log.info(x.getAuthority()));
        Page<CompanyUserResponse> pageResult = companyUserService.getAllCompanyUser(status, role, pageable);
        return ApiResponse.success(new PagedModel<>(pageResult));
    }
    @PostMapping("/member")
    ApiResponse<CompanyUserResponse> createCompanyUser(@RequestBody @Valid CompanyUserCrRequest request){

        return ApiResponse.success(companyUserService.createCompanyUser(request));
//        log.info("end controller");
    }
    @PatchMapping("/updateStaff")
    ApiResponse<CompanyUserResponse> updateCompanyUser(@RequestBody @Valid CompanyUserCrRequest request){

        return ApiResponse.success(companyUserService.createCompanyUser(request));
//        log.info("end controller");
    }
}
