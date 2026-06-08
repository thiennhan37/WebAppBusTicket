package com.example.BusTicket.specification;

import com.example.BusTicket.entity.Conversation;
import com.example.BusTicket.entity.Route;
import org.springframework.data.jpa.domain.Specification;

public class ConversationSpecification {

    public static Specification<Conversation> containsCustomerInfo(String customerInfo) {
        return (root, query, cb) -> {
            if(customerInfo == null || customerInfo.isBlank()) return cb.conjunction();
            String pattern = "%" + customerInfo.toLowerCase() + "%";
            return cb.or(
                    cb.like(cb.lower(root.get("customer").get("fullName")), pattern),
                    cb.like(cb.lower(root.get("customer").get("phone")), pattern)
            );
        };
    }
    public static Specification<Conversation> containsCompanyInfo(String companyInfo) {
        return (root, query, cb) -> {
            if(companyInfo == null || companyInfo.isBlank()) return cb.conjunction();
            String pattern = "%" + companyInfo.toLowerCase() + "%";
            return cb.or(
                    cb.like(cb.lower(root.get("busCompany").get("companyName")), pattern),
                    cb.like(cb.lower(root.get("busCompany").get("hotline")), pattern)
            );
        };
    }
    public static Specification<Conversation> hasCustomerId(String id) {
        return (root, query, cb) -> {
            if(id == null || id.isBlank()) return cb.conjunction();
            return cb.equal(root.get("customer").get("id"), id.trim());
        };
    }
    public static Specification<Conversation> hasBusCompanyId(String id) {
        return (root, query, cb) -> {
            if(id == null || id.isBlank()) return cb.conjunction();
            return cb.equal(root.get("busCompany").get("id"), id.trim());
        };
    }

}
