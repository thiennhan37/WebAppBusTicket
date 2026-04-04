package com.example.BusTicket.controller;


import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.entity.Province;
import com.example.BusTicket.entity.Stop;
import com.example.BusTicket.service.ProvinceService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController

@RequiredArgsConstructor
@Slf4j
public class ProvinceController {
    private final ProvinceService provinceService;

    @GetMapping("/provinces")
    ApiResponse<List<Province>> searchProvinces(@RequestParam(required = false) String keyword, Pageable pageable){
        return ApiResponse.success(provinceService.searchProvinces(keyword, pageable));
    }
    @GetMapping("/stops")
    ApiResponse<List<Stop>> findAllStops(@RequestParam(required = true) String province,
                                         @RequestParam(required = false) String keyword,
                                         Pageable pageable){
        return ApiResponse.success(provinceService.findAllStops(province, keyword, pageable));
    }
    //    @GetMapping("/route")
//    ApiResponse<PagedModel<Route>> getAllCompanyUser(@RequestParam(required = false) String status,
//                                                     @RequestParam(required = false) String role,
//                                                     @PageableDefault(page = 0, size = 5) Pageable pageable){
//
//        Pageable fixedPageable = PageRequest.of(pageable.getPageNumber(), 5);
//        Page<CompanyUserResponse> pageResult = companyUserService.getAllCompanyUser(status, role, fixedPageable);
//        return ApiResponse.success(new PagedModel<>(pageResult));
//    }
//    @PutMapping("/member/{id}")
//    ApiResponse<CompanyUserResponse> updateCompanyUser(@PathVariable String id,
//          @RequestHeader("Authorization") String bearerToken, @RequestBody @Valid CompanyUserUpRequest request)
//            throws ParseException, JOSEException
//    {
//        String token = bearerToken.replace("Bearer ", "");
//        return ApiResponse.success(companyUserService.updateCompanyUser(token, request));
//    }
}
