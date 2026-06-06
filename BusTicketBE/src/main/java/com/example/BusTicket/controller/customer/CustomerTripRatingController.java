package com.example.BusTicket.controller.customer;

import com.example.BusTicket.dto.request.TripRatingRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.BusCompanyRatingResponse;
import com.example.BusTicket.dto.response.DetailRatingResponse;
import com.example.BusTicket.service.TripRatingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class CustomerTripRatingController {
    private final TripRatingService tripRatingService;

    @PostMapping("/customer/orders/{orderId}/rating")
    public ApiResponse<Boolean> rateTrip(@PathVariable String orderId,
                                         @Valid @RequestBody TripRatingRequest request) {
        tripRatingService.rateTrip(orderId, request);
        return ApiResponse.success(true);
    }

    @GetMapping("/customer/orders/{orderId}/rating")
    public ApiResponse<DetailRatingResponse> getCustomerTripRating(@PathVariable String orderId) {
        return ApiResponse.success(tripRatingService.getCustomerTripRating(orderId));
    }

    @GetMapping("/customer/companies/{companyId}/rating")
    public ApiResponse<BusCompanyRatingResponse> getCompanyRating(@PathVariable String companyId) {
        return ApiResponse.success(tripRatingService.getCompanyRating(companyId));
    }
}
