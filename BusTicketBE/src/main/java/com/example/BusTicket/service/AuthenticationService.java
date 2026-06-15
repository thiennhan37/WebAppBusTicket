package com.example.BusTicket.service;

import com.example.BusTicket.dto.JwtObject.JwtHelper;
import com.example.BusTicket.dto.JwtObject.JwtInfo;
import com.example.BusTicket.dto.request.*;
import com.example.BusTicket.dto.response.*;
import com.example.BusTicket.dto.general.InfoAccount;
import com.example.BusTicket.entity.Admin;
import com.example.BusTicket.entity.CompanyRegister;
import com.example.BusTicket.entity.CompanyUser;
import com.example.BusTicket.entity.Customer;
import com.example.BusTicket.enums.AccountType;
import com.example.BusTicket.enums.RegisterType;
import com.example.BusTicket.enums.RoleEnum;
import com.example.BusTicket.enums.StatusEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.AdminMapper;
import com.example.BusTicket.mapper.CompanyRegisterMapper;
import com.example.BusTicket.mapper.CompanyUserMapper;
import com.example.BusTicket.mapper.CustomerMapper;
import com.example.BusTicket.repository.jpa.*;
import com.nimbusds.jose.JOSEException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestClient;

import java.util.Map;
import java.util.UUID;

import java.time.LocalDateTime;
import java.util.Random;


import java.text.ParseException;
import java.time.Duration;
import java.util.Date;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthenticationService {
    private final AdminRepository adminRepository;
    private final JwtService jwtService;
    private final CompanyUserRepository companyUserRepository;
    private final PasswordEncoder passwordEncoder;
    private final RedisTemplate<String, String> redisTemplate;
    private final CompanyUserMapper companyUserMapper;
    private final AdminMapper adminMapper;
    private final CompanyRegisterRepository companyRegisterRepository;
    private final BusCompanyRepository busCompanyRepository;
    private final CompanyRegisterMapper companyRegisterMapper;
    private final CustomerRepository customerRepository;
    private final CustomerMapper customerMapper;
    private final MailService mailService;
    private final SendMailService sendMailService;
    private final AuthAttemptService authAttemptService;

    @Value("${jwt.accessTime}")
    private long accessTime;
    @Value("${jwt.refreshTime}")
    private long refreshTime;

    @Value("${google.oauth.client-id:}")
    private String googleClientId;
    @Value("${google.oauth.client-secret:}")
    private String googleClientSecret;
    @Value("${google.oauth.redirect-uri:http://localhost:5174/khachhang/dang-nhap}")
    private String googleRedirectUri;
    @Value("${google.oauth.mobile-client-ids:}")
    private String googleMobileClientIds;

    public AuthenticationResponse loginCompany(LoginRequest request)
            throws JOSEException
    {
        InfoAccount account = null;
        account = companyUserRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new MyAppException(ErrorCode.UNAUTHENTICATED));

        boolean isAuthenticated = passwordEncoder.matches(request.getPassword(), account.getPassword());
        if(!isAuthenticated) throw new MyAppException(ErrorCode.UNAUTHENTICATED);
        if(account.getStatus().equals(StatusEnum.BLOCKED.name())){
            throw new MyAppException(ErrorCode.ACCOUNT_BLOCKED);
        }
        CompanyUser user = (CompanyUser) account;
        if(user.getBusCompany().getStatus().equals(StatusEnum.BLOCKED.name()))
            throw new MyAppException(ErrorCode.COMPANY_BLOCKED);
        String accessToken = jwtService.generateToken(account, accessTime);
        String refreshToken = jwtService.generateToken(account, refreshTime);


        CompanyUserResponse userResponse = companyUserMapper.toCompanyUserResponse(user);
        return AuthenticationResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .user(userResponse)
                .company(user.getBusCompany())
                .build();
    }
    public AdminLoginResponse loginAdmin(LoginRequest request)
            throws JOSEException
    {
        Admin account = adminRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new MyAppException(ErrorCode.LOGIN_FAILED));

        boolean isAuthenticated = passwordEncoder.matches(request.getPassword(), account.getPassword());
        if(!isAuthenticated) throw new MyAppException(ErrorCode.LOGIN_FAILED);
        if(account.getStatus().equals(StatusEnum.BLOCKED.name())){
            throw new MyAppException(ErrorCode.ACCOUNT_BLOCKED);
        }
        String accessToken = jwtService.generateToken(account, accessTime);
        String refreshToken = jwtService.generateToken(account, refreshTime);

        return AdminLoginResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .user(adminMapper.toAdminResponse(account))
                .build();
    }

    public void logout(LogoutRequest request, String refreshToken) throws ParseException, JOSEException {
        String accessToken = request.getAccessToken();

        saveInvalidToken(accessToken);
        saveInvalidToken(refreshToken);
    }

    public void changePassword(ChangePasswordRequest request){
        Jwt jwt = JwtHelper.getJwt();
        String userId = jwt.getSubject();

        CompanyUser user = null;
        if(jwt.getClaim("role").equals(RoleEnum.MANAGER.name()) || jwt.getClaim("role").equals(RoleEnum.STAFF.name())){
            user = companyUserRepository.findById(userId).orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));
        }
        else{
            throw new RuntimeException("Chưa tạo admin");
        }

        if (!passwordEncoder.matches(request.getOldPassword(), user.getPassword()))
            throw new MyAppException(ErrorCode.PASSWORD_NOT_MATCHES);
        if (passwordEncoder.matches(request.getNewPassword(), user.getPassword()))
            throw new MyAppException(ErrorCode.NEW_PASSWORD_DUPLICATE);

        String newPasswordEncoded = passwordEncoder.encode(request.getNewPassword());

        if(user instanceof CompanyUser){
            CompanyUser companyUser  = user;
            companyUser.setPassword(newPasswordEncoded);
            companyUserRepository.save(companyUser);
        }
        else{
            throw new RuntimeException("Chưa tạo admin");
        }
    }

    public void forgotPasswordCompany(String email) {
        if (email == null || email.isBlank()) {
            throw new MyAppException(ErrorCode.INVALID_PARAMETER);
        }

        CompanyUser user = companyUserRepository.findByEmail(email)
                .orElseThrow(() -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED));

        if (user.getStatus().equals(StatusEnum.BLOCKED.name())) {
            throw new MyAppException(ErrorCode.ACCOUNT_BLOCKED);
        }

        String newPassword = UUID.randomUUID().toString().substring(0, 8);
        user.setPassword(passwordEncoder.encode(newPassword));
        companyUserRepository.save(user);

        String companyName = user.getBusCompany() != null ? user.getBusCompany().getCompanyName() : null;
        sendMailService.sendForgotPasswordEmail(email, companyName, newPassword);
    }

    public CompanyRegister registerCompany(CompanyRegisterRequest request){
        if(busCompanyRepository.existsByEmail(request.getEmail())) throw new MyAppException(ErrorCode.EMAIL_EXISTED);
        if(busCompanyRepository.existsByHotline(request.getHotline())) throw new MyAppException(ErrorCode.HOTLINE_EXISTED);
        if(companyRegisterRepository.checkExistsInfo(request.getEmail(), request.getHotline()) != null)
            throw new MyAppException(ErrorCode.INFO_EXISTED);
        CompanyRegister companyRegister = companyRegisterMapper.toCompanyRegister(request);
        companyRegister.setStatus(RegisterType.PENDING.name());
        companyRegister.setUpdatedAt(LocalDateTime.now());
        sendMailService.sendPendingRegistrationEmail(request.getEmail(), request.getCompanyName());
        return companyRegisterRepository.save(companyRegister);
    }



    public RefreshTokenResponse refreshToken(String refreshToken)
            throws ParseException, JOSEException {

        JwtInfo jwtInfo = jwtService.parseToken(refreshToken);

        InfoAccount user = null;
        if(jwtInfo.getRole().equals(RoleEnum.STAFF.name()) || jwtInfo.getRole().equals(RoleEnum.MANAGER.name())){
            user = companyUserRepository.findById(jwtInfo.getSubject())
                    .orElseThrow(() -> new MyAppException(ErrorCode.UNAUTHENTICATED));
        }else if (jwtInfo.getRole().equals("CUSTOMER")) {
            user = customerRepository.findById(jwtInfo.getSubject())
                    .orElseThrow(() -> new MyAppException(ErrorCode.UNAUTHENTICATED));
        } else{
            user = adminRepository.findById(jwtInfo.getSubject())
                    .orElseThrow(() -> new MyAppException(ErrorCode.UNAUTHENTICATED));
        }

        saveInvalidToken(refreshToken);
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

    public void sendOtp(String email) {
        authAttemptService.assertNotBlocked("customer-login-otp", email);
        Customer customer = customerRepository.findByEmail(email)
                .orElseThrow(() -> new MyAppException(ErrorCode.INVALID_GMAIL));

        if (customer.getStatus().equals(StatusEnum.BLOCKED.name())) {
            throw new MyAppException(ErrorCode.ACCOUNT_BLOCKED);
        }

        String otp = generateOtp();
        String redisKey = "OTP_Login:" + email;
        redisTemplate.opsForValue().set(redisKey, otp, Duration.ofMinutes(5));

        // Tạo HTML email
        String htmlBody = "<div style='font-family: Arial, sans-serif;'>" +
                "<h2>Mã OTP của bạn</h2>" +
                "<p>Mã OTP để đăng nhập là: <strong style='font-size: 20px; color: #007bff;'>" + otp + "</strong></p>" +
                "<p>Mã này có hiệu lực trong 5 phút.</p>" +
                "<p>Nếu bạn không yêu cầu mã này, vui lòng bỏ qua.</p>" +
                "</div>";

        mailService.sendHtmlMail(email, "Mã OTP đăng nhập", htmlBody, null, null);
    }

    // Helper method
    private String generateOtp() {
        Random random = new Random();
        return String.format("%06d", random.nextInt(999999));
    }

    public CustomerAuthenticationResponse verifyOtp(String email, String otp) throws JOSEException {
        authAttemptService.assertNotBlocked("customer-login-otp", email);
        String redisKey = "OTP_Login:" + email;
        String storedOtp = redisTemplate.opsForValue().get(redisKey);

        if (storedOtp == null || !storedOtp.equals(otp)) {
            authAttemptService.recordFailure("customer-login-otp", email);
            throw new MyAppException(ErrorCode.INVALID_OTP);  // OTP sai hoặc hết hạn
        }

        // Xóa OTP sau verify thành công
        redisTemplate.delete(redisKey);
        authAttemptService.reset("customer-login-otp", email);

        Customer customer = customerRepository.findByEmail(email)
                .orElseThrow(() -> new MyAppException(ErrorCode.UNAUTHENTICATED));

        if (customer.getStatus().equals(StatusEnum.BLOCKED.name())) {
            throw new MyAppException(ErrorCode.ACCOUNT_BLOCKED);
        }

        String accessToken = jwtService.generateToken(customer, accessTime);
        String refreshToken = jwtService.generateToken(customer, refreshTime);
        CustomerInfoResponse customerInfo = customerMapper.toCustomerInfoResponse(customer);

        return CustomerAuthenticationResponse.builder()
                .customerInfo(customerInfo)
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }

    public String buildGoogleLoginUrl() {
        if (googleClientId == null || googleClientId.isBlank()) {
            throw new MyAppException(ErrorCode.INVALID_PARAMETER);
        }
        return "https://accounts.google.com/o/oauth2/v2/auth" +
                "?client_id=" + googleClientId +
                "&redirect_uri=" + googleRedirectUri +
                "&response_type=code&scope=openid%20email%20profile&access_type=offline&prompt=consent";
    }

    public CustomerAuthenticationResponse loginCustomerWithGoogle(String code) throws JOSEException {
        if (googleClientId == null || googleClientId.isBlank() || googleClientSecret == null || googleClientSecret.isBlank()) {
            throw new MyAppException(ErrorCode.INVALID_PARAMETER);
        }

        RestClient restClient = RestClient.builder().build();
        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("code", code);
        form.add("client_id", googleClientId);
        form.add("client_secret", googleClientSecret);
        form.add("redirect_uri", googleRedirectUri);
        form.add("grant_type", "authorization_code");

        Map tokenResponse = restClient.post()
                .uri("https://oauth2.googleapis.com/token")
                .body(form)
                .retrieve()
                .body(Map.class);

        String accessTokenGoogle = tokenResponse == null ? null : (String) tokenResponse.get("access_token");
        if (accessTokenGoogle == null) {
            throw new MyAppException(ErrorCode.UNAUTHENTICATED);
        }

        Map userInfo = restClient.get()
                .uri("https://www.googleapis.com/oauth2/v3/userinfo")
                .header("Authorization", "Bearer " + accessTokenGoogle)
                .retrieve()
                .body(Map.class);

        String email = userInfo == null ? null : (String) userInfo.get("email");
        if (email == null || email.isBlank()) {
            throw new MyAppException(ErrorCode.UNAUTHENTICATED);
        }

        Customer customer = customerRepository.findByEmail(email).orElseGet(() -> customerRepository.save(Customer.builder()
                .id(com.example.BusTicket.util.IdUtil.generateID())
                .email(email)
                .fullName((String) userInfo.get("name"))
                .status(StatusEnum.ACTIVE)
                .createdAt(LocalDateTime.now())
                .role("CUSTOMER")
                .build()));

        if (customer.getStatus().equals(StatusEnum.BLOCKED.name())) {
            throw new MyAppException(ErrorCode.ACCOUNT_BLOCKED);
        }

        String accessToken = jwtService.generateToken(customer, accessTime);
        String refreshToken = jwtService.generateToken(customer, refreshTime);
        CustomerInfoResponse customerInfo = customerMapper.toCustomerInfoResponse(customer);

        return CustomerAuthenticationResponse.builder()
                .customerInfo(customerInfo)
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }


    public CustomerAuthenticationResponse loginCustomerWithGoogleIdToken(String idToken) throws JOSEException {
        if (idToken == null || idToken.isBlank()) {
            throw new MyAppException(ErrorCode.INVALID_PARAMETER);
        }

        RestClient restClient = RestClient.builder().build();
        Map tokenInfo = restClient.get()
                .uri("https://oauth2.googleapis.com/tokeninfo?id_token={idToken}", idToken)
                .retrieve()
                .body(Map.class);

        if (tokenInfo == null) {
            throw new MyAppException(ErrorCode.UNAUTHENTICATED);
        }

        String email = (String) tokenInfo.get("email");
        String emailVerified = (String) tokenInfo.get("email_verified");
        String audience = (String) tokenInfo.get("aud");
        String name = (String) tokenInfo.get("name");

        if (email == null || email.isBlank() || !"true".equalsIgnoreCase(emailVerified)) {
            throw new MyAppException(ErrorCode.UNAUTHENTICATED);
        }

        if (googleMobileClientIds == null || googleMobileClientIds.isBlank()) {
            throw new MyAppException(ErrorCode.INVALID_PARAMETER);
        }

        boolean audienceAllowed = java.util.Arrays.stream(googleMobileClientIds.split(","))
                .map(String::trim)
                .anyMatch(clientId -> clientId.equals(audience));
        if (!audienceAllowed) {
            throw new MyAppException(ErrorCode.UNAUTHENTICATED);
        }

        Customer customer = customerRepository.findByEmail(email).orElseThrow(
                () -> new MyAppException(ErrorCode.ACCOUNT_NOT_EXISTED)
        );

        if (customer.getStatus().equals(StatusEnum.BLOCKED.name())) {
            throw new MyAppException(ErrorCode.ACCOUNT_BLOCKED);
        }

        String accessToken = jwtService.generateToken(customer, accessTime);
        String refreshToken = jwtService.generateToken(customer, refreshTime);
        CustomerInfoResponse customerInfo = customerMapper.toCustomerInfoResponse(customer);

        return CustomerAuthenticationResponse.builder()
                .customerInfo(customerInfo)
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }

    public CustomerAuthenticationResponse registerCustomerWithGoogleIdToken(String idToken, UpdateCustomerProfileRequest profile) throws JOSEException {
        if (idToken == null || idToken.isBlank()) {
            throw new MyAppException(ErrorCode.INVALID_PARAMETER);
        }

        RestClient restClient = RestClient.builder().build();
        Map tokenInfo = restClient.get()
                .uri("https://oauth2.googleapis.com/tokeninfo?id_token={idToken}", idToken)
                .retrieve()
                .body(Map.class);

        if (tokenInfo == null) {
            throw new MyAppException(ErrorCode.UNAUTHENTICATED);
        }

        String email = (String) tokenInfo.get("email");
        String emailVerified = (String) tokenInfo.get("email_verified");
        String audience = (String) tokenInfo.get("aud");
        String name = (String) tokenInfo.get("name");

        if (email == null || email.isBlank() || !"true".equalsIgnoreCase(emailVerified)) {
            throw new MyAppException(ErrorCode.UNAUTHENTICATED);
        }

        if (googleMobileClientIds == null || googleMobileClientIds.isBlank()) {
            throw new MyAppException(ErrorCode.INVALID_PARAMETER);
        }

        boolean audienceAllowed = java.util.Arrays.stream(googleMobileClientIds.split(","))
                .map(String::trim)
                .anyMatch(clientId -> clientId.equals(audience));
        if (!audienceAllowed) {
            throw new MyAppException(ErrorCode.UNAUTHENTICATED);
        }

        if (customerRepository.existsByEmail(email)) {
            throw new MyAppException(ErrorCode.EMAIL_EXISTED);
        }

        String fullName = (profile != null && profile.getFullName() != null && !profile.getFullName().isBlank())
                ? profile.getFullName() : name;

        Customer.CustomerBuilder customerBuilder = Customer.builder()
                .id(com.example.BusTicket.util.IdUtil.generateID())
                .email(email)
                .fullName(fullName)
                .status(StatusEnum.ACTIVE)
                .createdAt(LocalDateTime.now())
                .role("CUSTOMER");

        if (profile != null) {
            customerBuilder.phone(profile.getPhone());
            customerBuilder.dob(profile.getDob());
            customerBuilder.gender(profile.getGender());
        }

        Customer customer = customerRepository.save(customerBuilder.build());

        String accessToken = jwtService.generateToken(customer, accessTime);
        String refreshToken = jwtService.generateToken(customer, refreshTime);
        CustomerInfoResponse customerInfo = customerMapper.toCustomerInfoResponse(customer);

        return CustomerAuthenticationResponse.builder()
                .customerInfo(customerInfo)
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }
}
