package com.example.BusTicket.specification;

import com.example.BusTicket.entity.CompanyUser;
import com.example.BusTicket.entity.Customer;
import org.springframework.data.jpa.domain.Specification;

public class CustomerSpecification {

    public static Specification<Customer> hasStatus(String status){
        return (root, query, criteriaBuilder) ->{
            if(status == null) return criteriaBuilder.conjunction();
            return criteriaBuilder.equal(root.get("status"), status);
        };
    }
    public static Specification<Customer> containsKeyword(String keyword){
        return (root, query, criteriaBuilder) -> {
            if(keyword == null || keyword.isBlank()) return criteriaBuilder.conjunction();
            String pattern = "%" + keyword.toLowerCase() + "%";
            return criteriaBuilder.or(
                        criteriaBuilder.like(criteriaBuilder.lower(root.get("fullName")), pattern),
                        criteriaBuilder.like(criteriaBuilder.lower(root.get("id")), pattern),
                        criteriaBuilder.like(root.get("phone"), pattern)
                    );
        };
    }
}
