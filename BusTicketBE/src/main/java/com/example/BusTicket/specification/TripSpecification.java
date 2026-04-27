package com.example.BusTicket.specification;

import com.example.BusTicket.entity.Stop;
import com.example.BusTicket.entity.Trip;
import org.springframework.data.jpa.domain.Specification;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

public class TripSpecification {
    public static Specification<Trip> hasBuscompanyId(String busCompanyId) {
        return (root, query, cb) -> {
            if(busCompanyId == null || busCompanyId.isEmpty()) return cb.disjunction();
            return cb.equal(root.get("busCompany").get("id"), busCompanyId);
        };
    }

    public static Specification<Trip> hasStatus(String status) {
        return (root, query, cb) -> {
            if(status == null || status.isBlank()) return cb.conjunction();
            return cb.equal(root.get("status"), status);
        };
    }

    public static Specification<Trip> containsKeyword(String keyword) {
        return (root, query, cb) -> {
            if(keyword == null || keyword.isEmpty()) return cb.conjunction();
            String pattern = "%" + keyword.toLowerCase() + "%";
            return cb.or(
                    cb.like(cb.lower(root.get("route").get("arrivalProvince").get("name")), pattern),
                    cb.like(cb.lower(root.get("route").get("destinationProvince").get("name")), pattern),
                    cb.like(cb.lower(root.get("route").get("name")), pattern)
            );
        };
    }

    public static Specification<Trip> hasDate(LocalDate date) {
        return (root, query, cb) -> {
            if(date == null) return cb.conjunction();
            LocalDateTime startOfDay = date.atStartOfDay();
            LocalDateTime nextDay = date.plusDays(1).atStartOfDay();
            return cb.and(
                    cb.greaterThanOrEqualTo(root.get("departureTime"), startOfDay),
                    cb.lessThan(root.get("departureTime"), nextDay)
            );
        };
    }
    public static Specification<Trip> hasBusType(String busType) {
        return (root, query, cb) -> {
            if(busType == null) return cb.conjunction();
            return cb.equal(root.get("busType").get("name"), busType);
        };
    }
    public static Specification<Trip> hasArrivalProvince(String arrivalProvince) {
        return (root, query, cb) -> {
            if(arrivalProvince == null || arrivalProvince.isEmpty()) return cb.conjunction();
            return cb.equal(root.get("route").get("arrivalProvince").get("name"), arrivalProvince);
        };
    }
    public static Specification<Trip> hasDestinationProvince(String destinationProvince) {
        return (root, query, cb) -> {
            if(destinationProvince == null || destinationProvince.isEmpty()) return cb.conjunction();
            return cb.equal(root.get("route").get("destinationProvince").get("name"), destinationProvince);
        };
    }
}
