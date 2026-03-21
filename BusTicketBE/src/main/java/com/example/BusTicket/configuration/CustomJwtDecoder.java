package com.example.BusTicket.configuration;

import com.example.BusTicket.dto.JwtObject.JwtInfo;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.service.JwtService;
import com.nimbusds.jose.JOSEException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.stereotype.Component;

import javax.crypto.spec.SecretKeySpec;
import java.text.ParseException;
import java.util.Objects;

@Component
@RequiredArgsConstructor
public class CustomJwtDecoder implements JwtDecoder {
    private final JwtService jwtService;

    private NimbusJwtDecoder nimbusJwtDecoder = null;
    @Value("${jwt.signerKey}")
    private String signerKey;
    @Override
    public Jwt decode(String token) throws JwtException {
        try {
            JwtInfo jwtInfo = jwtService.parseToken(token);
            if(Objects.isNull(nimbusJwtDecoder)){
                SecretKeySpec secretKeySpec = new SecretKeySpec(signerKey.getBytes(), "HS256");
                nimbusJwtDecoder = NimbusJwtDecoder.withSecretKey(secretKeySpec)
                        .macAlgorithm(MacAlgorithm.HS256)
                        .build();
            }
        } catch (JOSEException | ParseException e) {
            throw new MyAppException(ErrorCode.INVALID_TOKEN);
        }

        return nimbusJwtDecoder.decode(token);

    }
}
