package com.example.BusTicket.controller.admin;


import com.example.BusTicket.dto.request.CompanyRegisterRequest;
import com.example.BusTicket.dto.request.CompanyUpRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.entity.Admin;
import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.CompanyRegister;
import com.example.BusTicket.service.AdminService;
import com.nimbusds.jose.JOSEException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PagedModel;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
@Slf4j
public class AdminController {
    private final AdminService adminService;

    // test
    @PostMapping("/create")
    ApiResponse<Admin> createAdmin(@RequestBody Map<String, String> request) throws JOSEException {
        return ApiResponse.success(adminService.createAdmin(request));
    }
    @GetMapping("/company-page")
    ApiResponse<PagedModel<BusCompany>> getCompanyPage(@RequestParam(required = false) String keyword,
                                                    @RequestParam(required = false) String status,
                                                    Pageable pageable){
        Page<BusCompany> result = adminService.getCompanyPage(keyword, status, pageable);
        return ApiResponse.success(new PagedModel<>(result));
    }
    @PutMapping("/company-status/{id}")
    ApiResponse<Boolean> updateStatus(@PathVariable(value = "id") String busCompanyId, @RequestBody CompanyUpRequest request){
        adminService.updateStatus(busCompanyId, request);
        return ApiResponse.success(true);
    }

    @GetMapping("/company-register-page")
    ApiResponse<PagedModel<CompanyRegister>> getCompanyRegisterPage(@RequestParam(required = false) String keyword,
                                                        @RequestParam(required = false) String reviewedName,
                                                        @RequestParam(required = false) String status,
                                                        Pageable pageable){
        Page<CompanyRegister> result = adminService.getCompanyRegisterPage(keyword, reviewedName, status, pageable);
        return ApiResponse.success(new PagedModel<>(result));
    }
    @PostMapping("/company-register/accepted")
    ApiResponse<Boolean> acceptCompanyRegister(@RequestBody CompanyRegister request){
        adminService.acceptCompanyRegister(request);
        return ApiResponse.success(true);
    }
    @PostMapping("/company-register/rejected")
    ApiResponse<Boolean> rejectCompanyRegister(@RequestBody CompanyRegister request){
        adminService.rejectCompanyRegister(request);
        return ApiResponse.success(true);
    }


}
