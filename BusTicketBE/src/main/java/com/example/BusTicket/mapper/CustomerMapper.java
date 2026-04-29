package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.request.CustomerRegisterRequest;
import com.example.BusTicket.dto.response.CustomerInfoResponse;
import com.example.BusTicket.entity.Customer;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring")
public interface CustomerMapper {
    CustomerInfoResponse toCustomerInfoResponse(Customer customer);
    List<CustomerInfoResponse> toCustomerInfoResponseList(List<Customer> customerList);
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "gender", ignore = true) // Sẽ set mặc định ở Service
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "role", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    Customer toEntity(CustomerRegisterRequest request);
}