package com.example.BusTicket.repository.jpa;

import com.example.BusTicket.entity.UserDeviceToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserDeviceTokenRepository extends JpaRepository<UserDeviceToken, Long> {
    Optional<UserDeviceToken> findByDeviceToken(String token);
    List<UserDeviceToken> findAllByUser_Id(String userId);
}
