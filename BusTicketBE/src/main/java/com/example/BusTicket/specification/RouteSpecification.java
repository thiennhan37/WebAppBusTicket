package com.example.BusTicket.specification;

import com.example.BusTicket.entity.Route;
import com.example.BusTicket.entity.Stop;
import org.springframework.data.jpa.domain.Specification;

public class RouteSpecification {
    public static Specification<Route> hasArrival(String provinceId) {
        return (root, query, cb) -> {
            if(provinceId == null) return cb.conjunction();
            return cb.equal(root.get("province").get("id"), provinceId);
        };
    }
    public static Specification<Route> hasDestination(String provinceId) {
        return (root, query, cb) -> {
            if(provinceId == null) return cb.conjunction();
            return cb.equal(root.get("province").get("id"), provinceId);
        };
    }
    public static Specification<Route> hasBusCompany(String busCompanyId) {
        return (root, query, cb) -> {
            if(busCompanyId == null) return cb.conjunction();
            return cb.equal(root.get("busCompany").get("id"), busCompanyId);
        };
    }


//    public static Specification<Stop> containsKeyword(String keyword) {
//        return (root, query, cb) -> {
//            if(keyword == null) return cb.conjunction();
//            String pattern = "%" + keyword.toLowerCase() + "%";
//            return cb.or(
//                    cb.like(cb.lower(root.get("name")), pattern),
//                    cb.like(cb.lower(root.get("address")), pattern)
//            );
//        };
//    }
}
