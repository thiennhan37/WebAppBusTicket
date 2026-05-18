package com.example.BusTicket.specification;

import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.CompanyRegister;
import org.springframework.data.jpa.domain.Specification;

public class CompanyRegisterSpecification {
    public static Specification<CompanyRegister> hasStatus(String status){
        return (root, query, criteriaBuilder) ->{
            if(status == null) return criteriaBuilder.conjunction();
            return criteriaBuilder.equal(root.get("status"), status);
        };
    }
    public static Specification<CompanyRegister> containsKeyword(String keyword){
        return (root, query, criteriaBuilder) -> {
            if(keyword == null || keyword.isBlank()) return criteriaBuilder.conjunction();
            String pattern = "%" + keyword.toLowerCase() + "%";
            return criteriaBuilder.like(criteriaBuilder.lower(root.get("companyName")), pattern);
        };
    }
    public static Specification<CompanyRegister> hasReviewedName(String reviewedName){
        return (root, query, criteriaBuilder) ->{
            if(reviewedName == null || reviewedName.isBlank()) return criteriaBuilder.conjunction();
            return criteriaBuilder.equal(root.get("reviewedBy").get("fullName"), reviewedName);
        };
    }
}
