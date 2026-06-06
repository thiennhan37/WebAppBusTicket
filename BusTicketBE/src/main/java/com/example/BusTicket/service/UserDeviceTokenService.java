package com.example.BusTicket.service;

import com.example.BusTicket.entity.Customer;
import com.example.BusTicket.entity.UserDeviceToken;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.repository.jpa.CustomerRepository;
import com.example.BusTicket.repository.jpa.UserDeviceTokenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserDeviceTokenService {
    private final UserDeviceTokenRepository userDeviceTokenRepository;
    private final CustomerRepository customerRepository;

    @Transactional
    public UserDeviceToken saveToken(String userId, String token){
        Customer customer = customerRepository.findById(userId)
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        UserDeviceToken userDeviceToken = userDeviceTokenRepository.findByDeviceToken(token)
                .map(existing -> {
                    existing.setUser(customer);
                    existing.setDeviceToken(token);
                    return existing;
                }).orElseGet(() -> UserDeviceToken.builder()
                        .user(customer)
                        .deviceToken(token)
                        .build()
                );
        return userDeviceTokenRepository.save(userDeviceToken);
    }
}
