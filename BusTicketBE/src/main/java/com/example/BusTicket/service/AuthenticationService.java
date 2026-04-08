package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtInfo;
import com.example.BusTicket.dto.request.CompanyRegisterRequest;
import com.example.BusTicket.dto.request.LoginRequest;
import com.example.BusTicket.dto.request.LogoutRequest;
import com.example.BusTicket.dto.request.RefreshTokenRequest;
import com.example.BusTicket.dto.response.AuthenticationResponse;
import com.example.BusTicket.dto.general.InfoAccount;
import com.example.BusTicket.dto.response.CompanyUserResponse;
import com.example.BusTicket.dto.response.RefreshTokenResponse;
import com.example.BusTicket.entity.CompanyRegister;
import com.example.BusTicket.entity.CompanyUser;
import com.example.BusTicket.enums.AccountType;
import com.example.BusTicket.enums.RoleEnum;
import com.example.BusTicket.enums.StatusEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.CompanyRegisterMapper;
import com.example.BusTicket.mapper.CompanyUserMapper;
import com.example.BusTicket.repository.jpa.BusCompanyRepository;
import com.example.BusTicket.repository.jpa.CompanyRegisterRepository;
import com.example.BusTicket.repository.jpa.CompanyUserRepository;
import com.nimbusds.jose.JOSEException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import tools.jackson.core.ErrorReportConfiguration;

import java.text.ParseException;
import java.time.Duration;
import java.util.Date;

@Service
@RequiredArgsConstructor
public class AuthenticationService {
    private final JwtService jwtService;
    private final CompanyUserRepository companyUserRepository;
    private final PasswordEncoder passwordEncoder;
    private final RedisTemplate<String, String> redisTemplate;
    private final CompanyUserMapper companyUserMapper;
    private final CompanyRegisterRepository companyRegisterRepository;
    private final BusCompanyRepository busCompanyRepository;
    private final CompanyRegisterMapper companyRegisterMapper;

    @Value("${jwt.accessTime}")
    private long accessTime;
    @Value("${jwt.refreshTime}")
    private long refreshTime;

    public AuthenticationResponse login(AccountType type, LoginRequest request)
            throws JOSEException
    {
        InfoAccount account = null;
        if(type == AccountType.COMPANY){
            account = companyUserRepository.findByEmail(request.getEmail())
                    .orElseThrow(() -> new MyAppException(ErrorCode.UNAUTHENTICATED));
        }
        else{
            account = new CompanyUser();
        }

        boolean isAuthenticated = passwordEncoder.matches(request.getPassword(), account.getPassword());
        if(!isAuthenticated) throw new MyAppException(ErrorCode.UNAUTHENTICATED);
        if(account.getStatus().equals(StatusEnum.BLOCKED.name())){
            throw new MyAppException(ErrorCode.ACCOUNT_BLOCKED);
        }

        String accessToken = jwtService.generateToken(account, accessTime);
        String refreshToken = jwtService.generateToken(account, refreshTime);
        CompanyUser user = (CompanyUser) account;
        CompanyUserResponse userResponse = companyUserMapper.toCompanyUserResponse(user);
        return AuthenticationResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .user(userResponse)
                .company(user.getBusCompany())
                .build();
    }
    public void logout(LogoutRequest request) throws ParseException, JOSEException {
        String accessToken = request.getAccessToken();
        String refreshToken = request.getRefreshToken();

        saveInvalidToken(accessToken);
        saveInvalidToken(refreshToken);

    }
    public CompanyRegister registerCompany(CompanyRegisterRequest request){
        if(busCompanyRepository.existsByEmail(request.getEmail())) throw new MyAppException(ErrorCode.EMAIL_EXISTED);
        if(busCompanyRepository.existsByHotline(request.getHotline())) throw new MyAppException(ErrorCode.HOTLINE_EXISTED);

        return companyRegisterRepository.save(companyRegisterMapper.toCompanyRegister(request));
    }
    public RefreshTokenResponse refreshToken(RefreshTokenRequest request)
            throws ParseException, JOSEException {
        String refreshToken = request.getRefreshToken();
        JwtInfo jwtInfo = jwtService.parseToken(refreshToken);

        InfoAccount user = null;
        if(jwtInfo.getRole().equals(RoleEnum.STAFF.name()) || jwtInfo.getRole().equals(RoleEnum.MANAGER.name())){
            user = companyUserRepository.findById(jwtInfo.getSubject())
                    .orElseThrow(() -> new MyAppException(ErrorCode.UNAUTHENTICATED));
        }
        else{
            user = new CompanyUser();
        }
//        saveInvalidToken(refreshToken);
        String newAccessToken = jwtService.generateToken(user, accessTime);
        String newRefreshToken = jwtService.generateToken(user, refreshTime);
        return RefreshTokenResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .build();
    }
    private void saveInvalidToken(String token) throws ParseException, JOSEException {
        JwtInfo jwtInfo = jwtService.parseToken(token);
        String jwtId = jwtInfo.getJwtId();
        Date issueTime = jwtInfo.getIssueTime();
        Date expirationTime = jwtInfo.getExpirationTime();
        Date now = new Date();
        if(expirationTime.after(now)){
            long ttl = Duration.between(now.toInstant(), expirationTime.toInstant()).toSeconds();
            String redisKey = "InvalidToken:" + jwtId;
            redisTemplate.opsForValue().set(redisKey, "1", Duration.ofSeconds(ttl));
        }
    }
}
