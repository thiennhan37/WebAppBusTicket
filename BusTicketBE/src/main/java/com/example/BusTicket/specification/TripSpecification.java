package com.example.BusTicket.specification;

import com.example.BusTicket.entity.Stop;
import com.example.BusTicket.entity.Trip;
import org.springframework.data.jpa.domain.Specification;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Collection;

import com.example.BusTicket.entity.RouteStop;

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

    public static Specification<Trip> hasPriceRange(Long minPrice, Long maxPrice) {
        return (root, query, cb) -> {
            if (minPrice == null && maxPrice == null) return cb.conjunction();
            if (minPrice != null && maxPrice != null) return cb.between(root.get("price"), minPrice, maxPrice);
            if (minPrice != null) return cb.greaterThanOrEqualTo(root.get("price"), minPrice);
            return cb.lessThanOrEqualTo(root.get("price"), maxPrice);
        };
    }

    public static Specification<Trip> hasDepartureTimeRange(LocalTime from, LocalTime to) {
        return (root, query, cb) -> {
            if (from == null && to == null) return cb.conjunction();
            var departureTimeExpr = cb.function("TIME", LocalTime.class, root.get("departureTime"));
            if (from != null && to != null) return cb.between(departureTimeExpr, from, to);
            if (from != null) return cb.greaterThanOrEqualTo(departureTimeExpr, from);
            return cb.lessThanOrEqualTo(departureTimeExpr, to);
        };
    }

    public static Specification<Trip> hasPickupStop(Long pickupStopId) {
        return (root, query, cb) -> {
            if (pickupStopId == null) return cb.conjunction();
            var sq = query.subquery(Long.class);
            var rs = sq.from(RouteStop.class);
            sq.select(rs.get("id"));
            sq.where(
                    cb.equal(rs.get("route").get("id"), root.get("route").get("id")),
                    cb.equal(rs.get("type"), "UP"),
                    cb.equal(rs.get("stop").get("id"), pickupStopId)
            );
            return cb.exists(sq);
        };
    }

    public static Specification<Trip> hasDropoffStop(Long dropoffStopId) {
        return (root, query, cb) -> {
            if (dropoffStopId == null) return cb.conjunction();
            var sq = query.subquery(Long.class);
            var rs = sq.from(RouteStop.class);
            sq.select(rs.get("id"));
            sq.where(
                    cb.equal(rs.get("route").get("id"), root.get("route").get("id")),
                    cb.equal(rs.get("type"), "DOWN"),
                    cb.equal(rs.get("stop").get("id"), dropoffStopId)
            );
            return cb.exists(sq);
        };
    }

    public static Specification<Trip> withBusCompanyId(String busCompanyId) {
        return (root, query, cb) -> {
            if (busCompanyId == null || busCompanyId.isBlank()) return cb.conjunction();
            return cb.equal(root.get("busCompany").get("id"), busCompanyId);
        };
    }

    public static Specification<Trip> withBusTypeName(String busTypeName) {
        return (root, query, cb) -> {
            if (busTypeName == null || busTypeName.isBlank()) return cb.conjunction();
            return cb.equal(cb.lower(root.get("busType").get("name")), busTypeName.toLowerCase());
        };
    }

    public static Specification<Trip> withArrivalProvinceId(String arrivalProvinceId) {
        return (root, query, cb) -> {
            if (arrivalProvinceId == null || arrivalProvinceId.isBlank()) return cb.conjunction();
            return cb.equal(root.get("route").get("arrivalProvince").get("id"), arrivalProvinceId);
        };
    }

    public static Specification<Trip> withDestinationProvinceId(String destinationProvinceId) {
        return (root, query, cb) -> {
            if (destinationProvinceId == null || destinationProvinceId.isBlank()) return cb.conjunction();
            return cb.equal(root.get("route").get("destinationProvince").get("id"), destinationProvinceId);
        };
    }

    public static Specification<Trip> withStatuses(Collection<String> statuses) {
        return (root, query, cb) -> {
            if (statuses == null || statuses.isEmpty()) return cb.conjunction();
            return root.get("status").in(statuses);
        };
    }
}
