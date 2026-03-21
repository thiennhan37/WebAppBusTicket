package com.example.BusTicket.repository.redis;

import com.example.BusTicket.dto.JwtObject.InvalidToken;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface InvalidTokenRepository extends CrudRepository<InvalidToken, String> {
}
