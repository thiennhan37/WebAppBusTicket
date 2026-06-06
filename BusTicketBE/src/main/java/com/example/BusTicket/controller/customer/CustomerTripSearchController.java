package com.example.BusTicket.controller.customer;

import com.example.BusTicket.dto.response.ApiResponse;
import com.example.BusTicket.dto.response.CustomerTripSearchRespone;
import com.example.BusTicket.dto.response.CustomerSearchBusDiagramRespone;
import com.example.BusTicket.entity.Stop;
import com.example.BusTicket.service.ProvinceService;
import com.example.BusTicket.service.SearchTripService;
import com.example.BusTicket.service.TripService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.web.PagedModel;
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
    private final SearchTripService searchTripService;


    // Endpoint: GET /api/trips/search?startProvince=Hà Nội&endProvince=Sapa&date=20/05/2026
    @GetMapping("/search")
    public ApiResponse<?> searchTrips(
            @RequestParam String startProvince,
            @RequestParam String endProvince,
            @RequestParam @DateTimeFormat(pattern = "dd/MM/yyyy") LocalDate date,
            @RequestParam(required = false) Integer minPrice,
            @RequestParam(required = false) Integer maxPrice,
            @RequestParam(required = false) String busCompanyId,
            @RequestParam(required = false) List<String> busCompanyIds,
            @RequestParam(required = false) @DateTimeFormat(pattern = "HH:mm") java.time.LocalTime departureTimeFrom,
            @RequestParam(required = false) @DateTimeFormat(pattern = "HH:mm") java.time.LocalTime departureTimeTo,
            @RequestParam(required = false) Long pickupStopId,
            @RequestParam(required = false) List<Long> pickupStopIds,
            @RequestParam(required = false) Long dropoffStopId,
            @RequestParam(required = false) List<Long> dropoffStopIds,
            @RequestParam(required = false) String busType,
            @RequestParam(required = false) Double minRating,
            @RequestParam(required = false, defaultValue = "departure_asc") String sortBy,
            @RequestParam(required = false, defaultValue = "0") int page) {

        Page<CustomerTripSearchRespone> trips = tripService.findTrips(
                startProvince,
                endProvince,
                date,
                minPrice,
                maxPrice,
                busCompanyId,
                busCompanyIds,
                departureTimeFrom,
                departureTimeTo,
                pickupStopId,
                pickupStopIds,
                dropoffStopId,
                dropoffStopIds,
                busType,
                minRating,
                sortBy,
                page
        );
        return ApiResponse.success(new PagedModel<>(trips));
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

    @GetMapping("get-companies-info")
    public ApiResponse<?> getCompaniesInfo(
            @RequestParam String provinceID
    ){
        return  ApiResponse.success(searchTripService.getCompaniesInfo(provinceID));
    }
}