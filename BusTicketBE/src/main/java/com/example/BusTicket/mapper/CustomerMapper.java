package com.example.BusTicket.mapper;

import com.example.BusTicket.dto.response.CustomerInfoResponse;
import com.example.BusTicket.entity.Customer;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface CustomerMapper {
    CustomerInfoResponse toCustomerInfoResponse(Customer customer);
    List<CustomerInfoResponse> toCustomerInfoResponseList(List<Customer> customerList);
}