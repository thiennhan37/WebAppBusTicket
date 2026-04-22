package com.example.BusTicket.specification;

import com.example.BusTicket.entity.Stop;
import org.springframework.data.jpa.domain.Specification;

public class StopSpecification {
    public static Specification<Stop> hasProvinceName(String provinceName) {
        return (root, query, cb) -> {
            if(provinceName == null) return cb.conjunction();
            return cb.equal(root.get("province").get("name"), provinceName);
        };
    }

    public static Specification<Stop> containsKeyword(String keyword) {
        return (root, query, cb) -> {
            if(keyword == null || keyword.isBlank()) return cb.conjunction();
            String pattern = "%" + keyword.toLowerCase() + "%";
            return cb.or(
                    cb.like(cb.lower(root.get("name")), pattern)
            );
        };
    }
}
