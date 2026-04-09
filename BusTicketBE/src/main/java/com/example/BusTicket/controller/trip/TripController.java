package com.example.BusTicket.controller.trip;


import com.example.BusTicket.dto.request.TripCrRequest;
import com.example.BusTicket.dto.request.TripUpRequest;
import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.TripResponse;
import com.example.BusTicket.entity.BusType;
import com.example.BusTicket.service.BusService;
import com.example.BusTicket.service.TripService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

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
    @PutMapping("/trips/{id}")
    ApiResponse<TripResponse> updateTrip(@PathVariable("id") String tripId, @RequestBody TripUpRequest request){
        return ApiResponse.success(tripService.updateTrip(tripId, request));
    }
    @PutMapping("trips/open/{id}")
    ApiResponse<TripResponse> openTrip(@PathVariable("id") String tripId){
        return ApiResponse.success(tripService.openTrip(tripId));
    }

}
