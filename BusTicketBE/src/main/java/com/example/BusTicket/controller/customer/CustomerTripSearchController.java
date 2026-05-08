package com.example.BusTicket.controller.customer;

import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.CustomerTripSearchRespone;
import com.example.BusTicket.dto.response.CustomerSearchBusDiagramRespone;
import com.example.BusTicket.entity.Stop;
import com.example.BusTicket.service.ProvinceService;
import com.example.BusTicket.service.SearchTripService;
import com.example.BusTicket.service.TripService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/trips")
@RequiredArgsConstructor
public class CustomerTripSearchController {

    private final SearchTripService tripService;
    private final ProvinceService provinceService;


    // Endpoint: GET /api/trips/search?startProvince=Hà Nội&endProvince=Sapa&date=20/05/2026
    @GetMapping("/search")
    public ApiResponse<?> searchTrips(
            @RequestParam String startProvince,
            @RequestParam String endProvince,
            @RequestParam @DateTimeFormat(pattern = "dd/MM/yyyy") LocalDate date) {

        List<CustomerTripSearchRespone> trips = tripService.findTrips(startProvince, endProvince, date);
        return ApiResponse.success(trips);
    }

    @GetMapping("/stops")
    public ApiResponse<?> searchStops(
            @RequestParam String provinceID) {

        List<Stop> stops = provinceService.findAllStopsByIdProvince(provinceID);
         return ApiResponse.success(stops);
    }

    @GetMapping("/bus-diagram")
    public ApiResponse<?> searchBusDiagram(
            @RequestParam String tripId){
        CustomerSearchBusDiagramRespone diagram = tripService.getBusDiagram(tripId);
        return ApiResponse.success(diagram);
    }
}