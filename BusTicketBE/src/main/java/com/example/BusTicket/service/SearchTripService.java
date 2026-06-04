package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.response.BusCompanyRatingResponse;
import com.example.BusTicket.dto.response.CustomerTripSearchRespone;
import com.example.BusTicket.dto.response.CustomerSearchBusDiagramRespone;
import com.example.BusTicket.dto.response.SearchCompaniesResponse;
import com.example.BusTicket.entity.*;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.repository.jpa.*;
import com.example.BusTicket.specification.TripSpecification;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.*;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;
import com.example.BusTicket.specification.TripSpecification;
import org.springframework.data.jpa.domain.Specification;

@Service
@RequiredArgsConstructor
@Slf4j
public class SearchTripService {

    private final TripSearchRepository tripSearchRepository;
    private final ProvinceRepository provinceRepository;
    private final TripRepository tripRepository;
    private final RouteStopRepository routeStopRepository;
    private final TripSeatRepository tripSeatRepository;
    private final RedisTemplate<String, String> redisTemplate;
    private final TripRatingService tripRatingService;
    private final BusCompanyRepository busCompanyRepository;
    private final CustomerRepository customerRepository;

    @Value("${booking.holdingSeatPrefixKey}")
    private String holdingSeatPrefixKey;

    private static final DateTimeFormatter TIME_FORMAT = DateTimeFormatter.ofPattern("HH:mm");
    private static final int SEARCH_PAGE_SIZE = 7;

    public Page<CustomerTripSearchRespone> findTrips(
            String startProvince,
            String endProvince,
            LocalDate date,
            Integer minPrice,
            Integer maxPrice,
            String busCompanyId,
            List<String> busCompanyIds,
            LocalTime departureTimeFrom,
            LocalTime departureTimeTo,
            Long pickupStopId,
            List<Long> pickupStopIds,
            Long dropoffStopId,
            List<Long> dropoffStopIds,
            String busType,
            Double minRating,
            String sortBy,
            int page) {
        // Validate provinces
        validateProvinces(startProvince, endProvince);

        List<String> effectiveBusCompanyIds = normalizeStringList(busCompanyIds);
        if ((effectiveBusCompanyIds == null || effectiveBusCompanyIds.isEmpty()) && busCompanyId != null && !busCompanyId.isBlank()) {
            effectiveBusCompanyIds = List.of(busCompanyId);
        }

        List<Long> effectivePickupStopIds = normalizeLongList(pickupStopIds);
        if ((effectivePickupStopIds == null || effectivePickupStopIds.isEmpty()) && pickupStopId != null) {
            effectivePickupStopIds = List.of(pickupStopId);
        }

        List<Long> effectiveDropoffStopIds = normalizeLongList(dropoffStopIds);
        if ((effectiveDropoffStopIds == null || effectiveDropoffStopIds.isEmpty()) && dropoffStopId != null) {
            effectiveDropoffStopIds = List.of(dropoffStopId);
        }

        // Query danh sách trips
        Specification<Trip> spec = Specification.where(TripSpecification.withArrivalProvinceId(startProvince))
                .and(TripSpecification.withDestinationProvinceId(endProvince))
                .and(TripSpecification.hasDate(date))
                .and(TripSpecification.withStatuses(List.of("OPEN", "SCHEDULED")))
                .and(TripSpecification.hasPriceRange(minPrice == null ? null : minPrice.longValue(), maxPrice == null ? null : maxPrice.longValue()))
                .and(TripSpecification.withBusCompanyIds(effectiveBusCompanyIds))
                .and(TripSpecification.hasDepartureTimeRange(departureTimeFrom, departureTimeTo))
                .and(TripSpecification.hasAnyPickupStops(effectivePickupStopIds))
                .and(TripSpecification.hasAnyDropoffStops(effectiveDropoffStopIds))
                .and(TripSpecification.withBusTypeName(busType));

        Sort sort = buildSort(sortBy);


        List<CustomerTripSearchRespone> filteredTrips = tripRepository.findAll(spec, sort).stream()
                .map(this::buildTripSearchResponse)
                .filter(resp -> minRating == null || resp.getRating() >= minRating)
                .collect(Collectors.toList());
        int safePage = Math.max(page, 0);
        Pageable pageable = PageRequest.of(safePage, SEARCH_PAGE_SIZE, sort);
        int startIndex = Math.min((int) pageable.getOffset(), filteredTrips.size());
        int endIndex = Math.min(startIndex + pageable.getPageSize(), filteredTrips.size());
        return new PageImpl<>(filteredTrips.subList(startIndex, endIndex), pageable, filteredTrips.size());
    }


    private List<String> normalizeStringList(List<String> values) {
        if (values == null) return null;
        return values.stream().filter(Objects::nonNull).map(String::trim).filter(v -> !v.isEmpty()).distinct().toList();
    }

    private List<Long> normalizeLongList(List<Long> values) {
        if (values == null) return null;
        return values.stream().filter(Objects::nonNull).distinct().toList();
    }

    private Sort buildSort(String sortBy) {
        return switch (normalizeSortBy(sortBy)) {
            case "price_asc" -> Sort.by(Sort.Direction.ASC, "price");
            case "price_desc" -> Sort.by(Sort.Direction.DESC, "price");
            case "departure_desc" -> Sort.by(Sort.Direction.DESC, "departureTime");
            default -> Sort.by(Sort.Direction.ASC, "departureTime");
        };
    }

    private String normalizeSortBy(String sortBy) {
        if (sortBy == null || sortBy.isBlank()) {
            return "departure_asc";
        }

        return switch (sortBy.toLowerCase()) {
            case "price_asc", "price_desc", "departure_desc" -> sortBy.toLowerCase();
            default -> "departure_asc";
        };
    }


    public List<SearchCompaniesResponse> getCompaniesInfo(String provinceID){
        List<BusCompany> companies;
        if(provinceID == null || provinceID.isBlank()){
            companies = busCompanyRepository.findByStatus("ACTIVE");
        }else{
            provinceRepository.findById(provinceID)
                    .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
            companies = busCompanyRepository.findActiveCompaniesByProvinceId(provinceID);
        }
        return companies.stream().map(
                company -> {
                    BusCompanyRatingResponse rating = tripRatingService.getCompanyRating(company.getId());
                    return SearchCompaniesResponse.builder()
                            .busCompanyId(company.getId())
                            .busCompanyName(company.getCompanyName())
                            .rating(rating.getAvgStars())
                            .build();
                }
        ).collect(Collectors.toList());
    }

    /**
     * Build CustomerTripSearchRespone bằng cách kết hợp thông tin từ nhiều query
     */
    private CustomerTripSearchRespone buildTripSearchResponse(Trip trip) {
        String tripId = trip.getId();
        LocalDateTime departureTime = trip.getDepartureTime();
        String busCompanyName = trip.getBusCompany() != null ? trip.getBusCompany().getCompanyName() : "";
        int price = trip.getPrice() != null ? trip.getPrice().intValue() : 0;
        log.info("Building response for trip: {}", tripId);


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
        String companyId = trip.getBusCompany().getId();
        BusCompanyRatingResponse busCompanyRatingResponse = tripRatingService.getCompanyRating(trip.getBusCompany().getId());  // Default rating



        // Get bus type name
        String busTypeName = trip.getBusType() != null ? trip.getBusType().getName() : "Xe khách";

        return CustomerTripSearchRespone.builder()
            .tripId(tripId)
            .departureTime(departureTime.format(TIME_FORMAT))
            .arrivalTime(arrivalTime.format(TIME_FORMAT))
            .duration(duration)
            .departureStation(departureStation)
            .arrivalStation(arrivalStation)
            .price(price)
            .availableSeats(availableSeats)
            .busCompanyName(busCompanyName)
            .busType(busTypeName)
            .rating(busCompanyRatingResponse.getAvgStars())
            .reviewCount(busCompanyRatingResponse.getTotalRatings())
            .build();
    }

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

    /**
     * Lấy sơ đồ ghế cho một chuyến xe
     */
    public CustomerSearchBusDiagramRespone getBusDiagram(String tripId) {
        log.info("Getting bus diagram for trip: {}", tripId);

        // Lấy Trip entity
        Trip trip = tripRepository.findById(tripId)
            .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));

        // Lấy BusType
        BusType busType = trip.getBusType();
        if (busType == null) {
            throw new MyAppException(ErrorCode.NOT_EXISTED);
        }

        // Lấy danh sách ghế với trạng thái và giá
        List<TripSeat> tripSeats = tripSeatRepository.findAllByTripId(tripId);

        List<String> availableSeatIds = tripSeats.stream()
                .filter(seat -> "AVAILABLE".equals(seat.getStatus()))
                .map(TripSeat::getId)
                .toList();

        List<String> redisKeys = availableSeatIds.stream()
                .map(id -> holdingSeatPrefixKey + id)
                .toList();
        List<String> redisValues = redisKeys.isEmpty() ? List.of() : redisTemplate.opsForValue().multiGet(redisKeys);

        Map<String, Boolean> heldInRedis = new HashMap<>();
        for (int i = 0; i < availableSeatIds.size(); i++) {
            heldInRedis.put(availableSeatIds.get(i), redisValues != null && redisValues.get(i) != null);
        }

        // Map sang SeatInfo
        List<CustomerSearchBusDiagramRespone.SeatInfo> seatInfos = tripSeats.stream()
            .map(seat -> {
            String seatStatus = seat.getStatus();
            if ("AVAILABLE".equals(seatStatus) && Boolean.TRUE.equals(heldInRedis.get(seat.getId()))) {
                seatStatus = "HELD";
            }
            return CustomerSearchBusDiagramRespone.SeatInfo.builder()
                    .seatId(seat.getId())
                    .seatCode(seat.getSeat())
                    .status(seatStatus)
                    .price(seat.getPrice())
                    .build();
        })
            .collect(Collectors.toList());

        return CustomerSearchBusDiagramRespone.builder()
            .busTypeName(busType.getName())
            .diagram(busType.getDiagram())
            .seats(seatInfos)
            .build();
    }
}