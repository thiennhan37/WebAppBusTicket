package com.example.BusTicket.service;

import com.example.BusTicket.dto.request.CustomerRegisterRequest;
import com.example.BusTicket.dto.response.CustomerAuthenticationResponse;
import com.example.BusTicket.dto.response.CustomerInfoResponse;
import com.example.BusTicket.entity.Customer;
import com.example.BusTicket.enums.GenderEnum;
import com.example.BusTicket.enums.RoleEnum;
import com.example.BusTicket.enums.StatusEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.CustomerMapper;
import com.example.BusTicket.repository.jpa.CustomerRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Random;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class CustomerAuthService {

    private final CustomerRepository customerRepository;
    private final CustomerMapper customerMapper;
    private final RedisTemplate<String, String> redisTemplate;
    private final MailService mailService;
    private final ObjectMapper objectMapper;
    private final JwtService jwtService;

    @Value("${jwt.accessTime}")
    private long accessTime;
    @Value("${jwt.refreshTime}")
    private long refreshTime;

    public void initiateCustomerRegistration(CustomerRegisterRequest request) {
        try {
            if (customerRepository.existsByEmail(request.getEmail())) {
                throw new MyAppException(ErrorCode.EMAIL_EXISTED);
            }
            if (customerRepository.existsByPhone(request.getPhone())) {
                throw new MyAppException(ErrorCode.PHONE_EXISTED);
            }

            String otp = generateOtp();
            String otpKey = "OTP_REG:" + request.getEmail();
            String infoKey = "INFO_REG:" + request.getEmail();

            redisTemplate.opsForValue().set(otpKey, otp, Duration.ofMinutes(5));
            String requestJson = objectMapper.writeValueAsString(request);
            redisTemplate.opsForValue().set(infoKey, requestJson, Duration.ofMinutes(5));

            String htmlBody = "<div style='font-family: Arial, sans-serif;'>" +
                    "<h2>Mã OTP Đăng Ký Tài Khoản</h2>" +
                    "<p>Mã xác thực của bạn là: <strong style='font-size: 20px; color: #28a745;'>" + otp + "</strong></p>" +
                    "<p>Mã này có hiệu lực trong 5 phút. Vui lòng không chia sẻ cho bất kỳ ai.</p>" +
                    "</div>";

            mailService.sendHtmlMail(request.getEmail(), "Mã OTP Đăng ký", htmlBody, null, null);
        } catch (MyAppException e) {
            throw e;
        } catch (Exception e) {
            log.error("Lỗi đăng ký: ", e);
            throw new MyAppException(ErrorCode.SYSTEM_ERROR);
        }
    }

    public CustomerAuthenticationResponse verifyRegistrationOtp(String email, String otp) throws Exception {
        String otpKey = "OTP_REG:" + email;
        String infoKey = "INFO_REG:" + email;

        String storedOtp = redisTemplate.opsForValue().get(otpKey);
        if (storedOtp == null || !storedOtp.equals(otp)) {
            throw new MyAppException(ErrorCode.INVALID_OTP);
        }

        String infoJson = redisTemplate.opsForValue().get(infoKey);
        if (infoJson == null) {
            throw new MyAppException(ErrorCode.REGISTRATION_EXPIRED);
        }

        try {
            CustomerRegisterRequest request = objectMapper.readValue(infoJson, CustomerRegisterRequest.class);

            Customer newCustomer = customerMapper.toEntity(request);
            newCustomer.setId(UUID.randomUUID().toString());
            newCustomer.setGender(GenderEnum.OTHER);
            newCustomer.setStatus(StatusEnum.ACTIVE);
            newCustomer.setRole(RoleEnum.CUSTOMER.name());
            newCustomer.setCreatedAt(LocalDateTime.now());

            Customer savedCustomer = customerRepository.save(newCustomer);

            redisTemplate.delete(otpKey);
            redisTemplate.delete(infoKey);

            String accessToken = jwtService.generateToken(savedCustomer, accessTime);
            String refreshToken = jwtService.generateToken(savedCustomer, refreshTime);
            CustomerInfoResponse customerInfo = customerMapper.toCustomerInfoResponse(savedCustomer);

            return CustomerAuthenticationResponse.builder()
                    .customerInfo(customerInfo)
                    .accessToken(accessToken)
                    .refreshToken(refreshToken)
                    .build();
        } catch (Exception e) {
            // Bắt lỗi trong trường hợp parse JSON lỗi hoặc lưu DB lỗi
            throw new MyAppException(ErrorCode.SYSTEM_ERROR);
        }
    }

    // Helper method tạo OTP 6 số
    private String generateOtp() {
        Random random = new Random();
        return String.format("%06d", random.nextInt(999999));
    }
}