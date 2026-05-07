package com.example.BusTicket.service;

import com.example.BusTicket.dto.response.CustomerTripSearchRespone;
import com.example.BusTicket.entity.*;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.repository.jpa.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class SearchTripService {

    private final TripSearchRepository tripSearchRepository;
    private final ProvinceRepository provinceRepository;
    private final TripRepository tripRepository;
    private final RouteStopRepository routeStopRepository;

    private static final DateTimeFormatter TIME_FORMAT = DateTimeFormatter.ofPattern("HH:mm");

    public List<CustomerTripSearchRespone> findTrips(String startProvince, String endProvince, LocalDate date) {
        log.info("Searching trips with startProvince: {}, endProvince: {}, date: {}", 
            startProvince, endProvince, date);

        // Validate provinces
        validateProvinces(startProvince, endProvince);

        // Query danh sách trips
        List<Object[]> tripResults = tripSearchRepository.searchTrips(
            startProvince,
            endProvince,
            date
        );

        // Map sang CustomerTripSearchRespone
        return tripResults.stream()
            .map(result -> buildTripSearchResponse(
                (String) result[0],  // tripId
                (LocalDateTime) result[1],  // departureTime
                (String) result[2],  // routeName
                (String) result[3],  // busCompanyName
                ((Number) result[4]).intValue()  // price
            ))
            .collect(Collectors.toList());
    }

    /**
     * Build CustomerTripSearchRespone bằng cách kết hợp thông tin từ nhiều query
     */
    private CustomerTripSearchRespone buildTripSearchResponse(
            String tripId, 
            LocalDateTime departureTime,
            String routeName,
            String busCompanyName,
            int price) {
        
        log.info("Building response for trip: {}", tripId);

        // Lấy Trip entity để có thêm thông tin
        Trip trip = tripRepository.findById(tripId)
            .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));

        // Query 2: Lấy số ghế available
        int availableSeats = tripSearchRepository.getAvailableSeatsCount(tripId);

        // Tính thời gian dự kiến đến dựa trên durationMinutes từ Route
        LocalDateTime arrivalTime = departureTime;
        String duration = "0h 0m";
        
        if (trip.getRoute() != null && trip.getRoute().getDurationMinutes() != null) {
            int durationMinutes = trip.getRoute().getDurationMinutes();
            arrivalTime = departureTime.plusMinutes(durationMinutes);
            
            // Format duration: "6h 30m"
            int hours = durationMinutes / 60;
            int minutes = durationMinutes % 60;
            duration = hours + "h " + minutes + "m";
        }

        // Query 4: Lấy thông tin Station
        String departureStation = "Bến khởi hành";
        String arrivalStation = "Bến đến";
        
        if (trip.getRoute() != null && trip.getRoute().getId() != null) {
            String depStation = routeStopRepository.getDepartureStation(trip.getRoute().getId().intValue());
            String arrStation = routeStopRepository.getArrivalStation(trip.getRoute().getId().intValue());
            if (depStation != null) departureStation = depStation;
            if (arrStation != null) arrivalStation = arrStation;
        }

        // Query 5: Lấy rating
        double rating = 4.5;  // Default rating
        int reviewCount = 0;
        
        if (trip.getBusCompany() != null) {
            List<Object[]> ratingResults = getRatingAndReviewCount(trip.getBusCompany().getId());
            if (!ratingResults.isEmpty()) {
                Object[] ratingData = ratingResults.getFirst();
                rating = ratingData[0] != null ? ((Number) ratingData[0]).doubleValue() : 4.5;
                reviewCount = ratingData[1] != null ? ((Number) ratingData[1]).intValue() : 0;
            }
        }

        // Get bus type name
        String busTypeName = trip.getBusType() != null ? trip.getBusType().getName() : "Xe khách";

        return CustomerTripSearchRespone.builder()
            .departureTime(departureTime.format(TIME_FORMAT))
            .arrivalTime(arrivalTime.format(TIME_FORMAT))
            .duration(duration)
            .departureStation(departureStation)
            .arrivalStation(arrivalStation)
            .price(price)
            .availableSeats(availableSeats)
            .busCompanyName(busCompanyName)
            .busType(busTypeName)
            .rating(rating)
            .reviewCount(reviewCount)
            .build();
    }

    /**
     * Validate tỉnh khởi hành và tỉnh đến khác nhau
     */
    private void validateProvinces(String startProvince, String endProvince) {
        if (startProvince.equals(endProvince)) {
            throw new MyAppException(ErrorCode.VALIDATION_FAILED);
        }

        // Optionally validate that provinces exist
        provinceRepository.findById(startProvince)
            .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        
        provinceRepository.findById(endProvince)
            .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
    }

    /**
     * Helper: Lấy rating và review count
     */
    private List<Object[]> getRatingAndReviewCount(String busCompanyId) {
        return tripSearchRepository.getCompanyRatings(busCompanyId);
    }
}