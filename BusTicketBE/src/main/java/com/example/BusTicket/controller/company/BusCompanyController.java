package com.example.BusTicket.controller.company;


import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.service.BusCompanyService;
import com.example.BusTicket.service.CompanyUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.repository.query.Param;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/nhaxe")
@RequiredArgsConstructor
@Slf4j
public class BusCompanyController {
    private final CompanyUserService companyUserService;
    private final BusCompanyService busCompanyService;
    @GetMapping("/bus-company/{id}")
    ApiResponse<BusCompany> getBusCompany(@PathVariable("id") String busCompanyId){
        return ApiResponse.success(busCompanyService.getBusCompany(busCompanyId));
    }
    @PutMapping("/bus-company/{id}")
    ApiResponse<BusCompany> updateBusCompany(@PathVariable("id") String busCompanyId){
        return ApiResponse.success(busCompanyService.getBusCompany(busCompanyId));
    }


}
