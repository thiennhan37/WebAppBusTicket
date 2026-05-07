package com.example.BusTicket.controller.customer;

import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.CustomerTripSearchRespone;
import com.example.BusTicket.service.SearchTripService;
import com.example.BusTicket.service.TripService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/trips")
public class CustomerTripSearchController {

    @Autowired
    private SearchTripService tripService;

    // Endpoint: GET /api/trips/search?startProvince=Hà Nội&endProvince=Sapa&date=20/05/2026
    @GetMapping("/search")
    public ApiResponse<?> searchTrips(
            @RequestParam String startProvince,
            @RequestParam String endProvince,
            @RequestParam @DateTimeFormat(pattern = "dd/MM/yyyy") LocalDate date) {

        List<CustomerTripSearchRespone> trips = tripService.findTrips(startProvince, endProvince, date);
        return ApiResponse.success(trips);
    }
}