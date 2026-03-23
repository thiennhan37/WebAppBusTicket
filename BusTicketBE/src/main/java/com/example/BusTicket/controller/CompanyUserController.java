package com.example.BusTicket.controller;


import com.example.BusTicket.dto.request.CompanyUserCrRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.CompanyUserResponse;
import com.example.BusTicket.service.CompanyUserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/nhaxe")
@RequiredArgsConstructor
@Slf4j
public class CompanyUserController {
    private final CompanyUserService companyUserService;
    @GetMapping("/member")
    ApiResponse<List<CompanyUserResponse>> getAllCompanyUser(){
        return ApiResponse.success(companyUserService.getCompanyUserList());
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
