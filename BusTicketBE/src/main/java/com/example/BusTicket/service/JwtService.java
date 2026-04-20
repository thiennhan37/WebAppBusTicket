package com.example.BusTicket.service;

import com.example.BusTicket.dto.general.InfoAccount;
import com.example.BusTicket.dto.JwtObject.JwtInfo;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.nimbusds.jose.*;
import com.nimbusds.jose.crypto.MACSigner;
import com.nimbusds.jose.crypto.MACVerifier;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.text.ParseException;
import java.time.temporal.ChronoUnit;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class JwtService {
    private final RedisTemplate<String, String> redisTemplate;
    @Value("${jwt.signerKey}")
    private String signerKey;


    public String generateToken(InfoAccount user, long timer) throws JOSEException {
        JWSHeader jwsHeader = new JWSHeader(JWSAlgorithm.HS256);
        Date issueTime = new Date();
        Date expirationTime = new Date(issueTime.toInstant().plus(timer, ChronoUnit.SECONDS).toEpochMilli());


        JWTClaimsSet jwtClaimsSet = new JWTClaimsSet.Builder()
                .issuer("vexedat.com")
                .subject(user.getId())
                .issueTime(issueTime).expirationTime(expirationTime)
                .jwtID(UUID.randomUUID().toString())
                .claim("role", user.getRole())
                .claim("scope", user.getRole())
                .build();
        Payload payload = new Payload(jwtClaimsSet.toJSONObject());
        JWSObject jwsObject = new JWSObject(jwsHeader, payload);
        jwsObject.sign(new MACSigner(signerKey.getBytes()));

        return jwsObject.serialize();
    }

    public JwtInfo parseToken(String token)
            throws JOSEException, ParseException
    {
        JWSVerifier verifier = new MACVerifier(signerKey.getBytes());
        SignedJWT signedJWT = SignedJWT.parse(token);

        boolean isValid = signedJWT.verify(verifier);
        Date expirationTime = signedJWT.getJWTClaimsSet().getExpirationTime();
        String jwtId = signedJWT.getJWTClaimsSet().getJWTID();
        String redisKey = "InvalidToken:" + jwtId;
        if(redisTemplate.opsForValue().get(redisKey) != null){
            throw new MyAppException(ErrorCode.INVALID_TOKEN);
        }

        if( ! (isValid && expirationTime.after(new Date())) ){
            throw new MyAppException(ErrorCode.INVALID_TOKEN);
        }
        return JwtInfo.builder()
                .jwtId(signedJWT.getJWTClaimsSet().getJWTID())
                .subject(signedJWT.getJWTClaimsSet().getSubject())
                .role(signedJWT.getJWTClaimsSet().getClaimAsString("role"))
                .issueTime(signedJWT.getJWTClaimsSet().getIssueTime())
                .expirationTime(signedJWT.getJWTClaimsSet().getExpirationTime())
                .build();
    }
}
