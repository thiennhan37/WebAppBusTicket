package com.example.BusTicket.service;

import com.example.BusTicket.dto.request.CustomerRegisterRequest;
import com.example.BusTicket.dto.response.CustomerInfoResponse;
import com.example.BusTicket.entity.Customer;
import com.example.BusTicket.enums.GenderEnum;
import com.example.BusTicket.enums.RoleEnum;
import com.example.BusTicket.enums.StatusEnum;
import com.example.BusTicket.mapper.CustomerMapper;
import com.example.BusTicket.repository.jpa.CustomerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CustomerAuthService {
    private final CustomerRepository customerRepository;
    private final CustomerMapper customerMapper;

    public CustomerInfoResponse registerCustomer(CustomerRegisterRequest request) {
        if (customerRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email này đã được đăng ký trong hệ thống!");
        }
        if (customerRepository.existsByPhone(request.getPhone())) {
            throw new RuntimeException("Số điện thoại này đã được sử dụng!");
        }

        Customer newCustomer = customerMapper.toEntity(request);

        newCustomer.setId(UUID.randomUUID().toString());
        newCustomer.setPassword(null);
        newCustomer.setGender(GenderEnum.OTHER);
        newCustomer.setStatus(StatusEnum.ACTIVE);
        newCustomer.setRole("Customer");
        newCustomer.setCreatedAt(LocalDateTime.now());

        Customer savedCustomer = customerRepository.save(newCustomer);

        return customerMapper.toCustomerInfoResponse(savedCustomer);
    }


}
