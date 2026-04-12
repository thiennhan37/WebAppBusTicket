package com.example.BusTicket.controller.trip;


import com.example.BusTicket.dto.request.TripCrRequest;
import com.example.BusTicket.dto.request.TripUpRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.TripResponse;
import com.example.BusTicket.service.TripService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PagedModel;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController

@RequiredArgsConstructor
@Slf4j
@RequestMapping("/nhaxe")
public class TripController {
    private final TripService tripService;

    @PostMapping("/trips")
    ApiResponse<TripResponse> createTrip(@RequestBody TripCrRequest request){
        return ApiResponse.success(tripService.createTrip(request));
    }
    @GetMapping("/trips/{id}")
    ApiResponse<TripResponse> getTrip(@PathVariable("id") String tripId){
        return ApiResponse.success(tripService.getTrip(tripId));
    }
    @GetMapping("/trips")
    ApiResponse<PagedModel<TripResponse>> getAllTrips(@RequestParam(required = false) String status,
                                                      @RequestParam(required = false) String keyword,
                                                      @RequestParam(required = false) LocalDate date,
                                                      @RequestParam(required = false) String busType,
                                                      Pageable pageable){
        Page<TripResponse> result = tripService.getAllTrips(status, keyword, date, busType, pageable);
        return ApiResponse.success(new PagedModel<>(result));
    }
    @PutMapping("/trips/{id}")
    ApiResponse<TripResponse> updateTrip(@PathVariable("id") String tripId, @RequestBody TripUpRequest request){
        return ApiResponse.success(tripService.updateTrip(tripId, request));
    }
    @PutMapping("/trips/open/{id}")
    ApiResponse<TripResponse> openTrip(@PathVariable("id") String tripId){
        return ApiResponse.success(tripService.openTrip(tripId));
    }

}
