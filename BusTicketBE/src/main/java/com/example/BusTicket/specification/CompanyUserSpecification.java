package com.example.BusTicket.specification;

import com.example.BusTicket.entity.CompanyUser;
import org.springframework.data.jpa.domain.Specification;

public class CompanyUserSpecification {
    public static Specification<CompanyUser> hasStatus(String status){
        return (root, query, criteriaBuilder) ->{
            if(status == null) return criteriaBuilder.conjunction();
            return criteriaBuilder.equal(root.get("status"), status);
        };
    }
    public static Specification<CompanyUser> hasRole(String role){
        return (root, query, criteriaBuilder) ->{
            if(role == null) return criteriaBuilder.conjunction();
            return criteriaBuilder.equal(root.get("role"), role);
        };
    }
}
