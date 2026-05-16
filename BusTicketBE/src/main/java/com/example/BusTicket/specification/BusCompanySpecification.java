package com.example.BusTicket.specification;

import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.CompanyUser;
import org.springframework.data.jpa.domain.Specification;

public class BusCompanySpecification {
    public static Specification<BusCompany> hasStatus(String status){
        return (root, query, criteriaBuilder) ->{
            if(status == null) return criteriaBuilder.conjunction();
            return criteriaBuilder.equal(root.get("status"), status);
        };
    }
    public static Specification<BusCompany> containsKeyword(String keyword){
        return (root, query, criteriaBuilder) -> {
            if(keyword == null || keyword.isBlank()) return criteriaBuilder.conjunction();
            String pattern = "%" + keyword.toLowerCase() + "%";
            return criteriaBuilder.like(criteriaBuilder.lower(root.get("companyName")), pattern);
        };
    }
}
