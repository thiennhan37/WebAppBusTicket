package com.example.BusTicket.controller.company;


import com.example.BusTicket.dto.request.CompanyUserCrRequest;
import com.example.BusTicket.dto.request.CompanyUserUpRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.CompanyUserResponse;
import com.example.BusTicket.service.CompanyUserService;
import com.nimbusds.jose.JOSEException;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.data.web.PagedModel;
import org.springframework.web.bind.annotation.*;

import java.text.ParseException;

@RestController
@RequestMapping("/nhaxe")
@RequiredArgsConstructor
@Slf4j
public class CompanyUserController {
    private final CompanyUserService companyUserService;
    @GetMapping("/member")
    ApiResponse<PagedModel<CompanyUserResponse>> getAllCompanyUser(@RequestParam(required = false) String status,
           @RequestParam(required = false) String role,
           @PageableDefault(page = 0, size = 5) Pageable pageable){

//        var authenticate = SecurityContextHolder.getContext().getAuthentication();
//        log.info("username : {}", authenticate.getName());
//        authenticate.getAuthorities().forEach(x -> log.info(x.getAuthority()));
        Pageable fixedPageable = PageRequest.of(pageable.getPageNumber(), 5);
        Page<CompanyUserResponse> pageResult = companyUserService.getAllCompanyUser(status, role, fixedPageable);
        return ApiResponse.success(new PagedModel<>(pageResult));
    }
    @PostMapping("/member")
    ApiResponse<CompanyUserResponse> createCompanyUser(@RequestBody @Valid CompanyUserCrRequest request){

        return ApiResponse.success(companyUserService.createCompanyUser(request));
//        log.info("end controller");
    }
    @PutMapping("/member/{id}")
    ApiResponse<CompanyUserResponse> updateCompanyUser(@PathVariable String id, @RequestBody @Valid CompanyUserUpRequest request)
            throws ParseException, JOSEException
    {
        return ApiResponse.success(companyUserService.updateCompanyUser(request));
//        log.info("end controller");
    }
}
