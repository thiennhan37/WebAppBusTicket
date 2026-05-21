package com.example.BusTicket.controller.admin;


import com.example.BusTicket.dto.request.CompanyRegisterRequest;
import com.example.BusTicket.dto.request.CompanyUpRequest;
import com.example.BusTicket.dto.request.StatusUpRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.CompanyUserResponse;
import com.example.BusTicket.dto.response.CustomerInfoResponse;
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
    @GetMapping("/company/{id}")
    ApiResponse<BusCompany> getCompanyInfo(@PathVariable(value = "id") String busCompanyId){
        BusCompany result = adminService.getCompanyInfo(busCompanyId);
        return ApiResponse.success(result);
    }
    @GetMapping("/company-page")
    ApiResponse<PagedModel<BusCompany>> getCompanyPage(@RequestParam(required = false) String keyword,
                                                    @RequestParam(required = false) String status,
                                                    Pageable pageable){
        Page<BusCompany> result = adminService.getCompanyPage(keyword, status, pageable);
        return ApiResponse.success(new PagedModel<>(result));
    }
    @PutMapping("/company-status/{id}")
    ApiResponse<Boolean> updateCompanyStatus(@PathVariable(value = "id") String busCompanyId, @RequestBody StatusUpRequest request){
        adminService.updateCompanyStatus(busCompanyId, request);
        return ApiResponse.success(true);
    }
    @PutMapping("/customer-status/{id}")
    ApiResponse<Boolean> updateCustomerStatus(@PathVariable(value = "id") String customerId, @RequestBody StatusUpRequest request){
        adminService.updateCustomerStatus(customerId, request);
        return ApiResponse.success(true);
    }
    @PutMapping("/staff-status/{id}")
    ApiResponse<Boolean> updateStaffStatus(@PathVariable(value = "id") String customerId, @RequestBody StatusUpRequest request){
        adminService.updateStaffStatus(customerId, request);
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
    @PostMapping("/company-register/accepted/{id}")
    ApiResponse<Boolean> acceptCompanyRegister(@PathVariable(value = "id") String CompanyRegisterId){
        adminService.acceptCompanyRegister(CompanyRegisterId);
        return ApiResponse.success(true);
    }
    @PostMapping("/company-register/rejected/{id}")
    ApiResponse<Boolean> rejectCompanyRegister(@PathVariable(value = "id") String CompanyRegisterId){
        adminService.rejectCompanyRegister(CompanyRegisterId);
        return ApiResponse.success(true);
    }
    @GetMapping("/staff-page")
    ApiResponse<PagedModel<CompanyUserResponse>> getCompanyUserPage(@RequestParam(required = false) String keyword,
                                                                    @RequestParam(required = false) String status,
                                                                    Pageable pageable){
        Page<CompanyUserResponse> result = adminService.getCompanyUserPage(keyword, status, pageable);
        return ApiResponse.success(new PagedModel<>(result));
    }
    @GetMapping("/customer-page")
    ApiResponse<PagedModel<CustomerInfoResponse>> getCustomerPage(@RequestParam(required = false) String keyword,
                                                                     @RequestParam(required = false) String status,
                                                                     Pageable pageable){
        Page<CustomerInfoResponse> result = adminService.getCustomerPage(keyword, status, pageable);
        return ApiResponse.success(new PagedModel<>(result));
    }


}
