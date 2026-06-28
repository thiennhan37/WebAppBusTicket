package com.example.BusTicket.controller.customer;

import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.BusCompanyResponse;
import com.example.BusTicket.service.BusCompanyService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PagedModel;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class CustomerFindCompanyController {
    private final BusCompanyService busCompanyService;

    @GetMapping("/customer/companies-list")
    public ApiResponse<PagedModel<BusCompanyResponse>> getCompanyForCustomerChat(
            @RequestParam(required = false) String name,
            Pageable pageable) {
        return ApiResponse.success(new PagedModel<>(busCompanyService.getCompanyForCustomerChat(name, pageable)));
    }

    @GetMapping("/customer/companiesWithHighRating")
    public ApiResponse<?> getCompanyWithHighRating(){
        return ApiResponse.success(busCompanyService.getCompaniesWithHighRating());
    }
}
