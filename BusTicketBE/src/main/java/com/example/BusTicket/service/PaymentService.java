package com.example.BusTicket.service;

import com.example.BusTicket.configuration.MomoConfiguration;
import com.example.BusTicket.configuration.VNPayConfig;
import com.example.BusTicket.dto.general.ExtraDataDTO;
import com.example.BusTicket.dto.request.MomoPaymentRequest;
import com.example.BusTicket.dto.request.MomoRefundRequest;
import com.example.BusTicket.dto.request.PaymentRequest;
import com.example.BusTicket.dto.request.VNPayPaymentRequest;
import com.example.BusTicket.dto.response.MomoPaymentResponse;
import com.example.BusTicket.dto.response.MomoRefundResponse;
import com.example.BusTicket.dto.response.PaymentResponse;
import com.example.BusTicket.dto.response.PaymentUrlResponse;
import com.example.BusTicket.dto.response.VNPayPaymentResponse;
import com.example.BusTicket.dto.response.VNPayRefundResponse;
import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.entity.Payment;
import com.example.BusTicket.entity.Trip;
import com.example.BusTicket.enums.AccountType;
import com.example.BusTicket.enums.MomoEnum;
import com.example.BusTicket.enums.PaymentEnum;
import com.example.BusTicket.enums.TripStatusEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.PaymentMapper;
import com.example.BusTicket.repository.jpa.BookingOrderRepository;
import com.example.BusTicket.repository.jpa.PaymentRepository;
import com.example.BusTicket.util.MomoUtil;
import com.example.BusTicket.util.VNPayUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cglib.core.Local;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.Instant;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentService {
    private final PaymentRepository paymentRepository;
    private final PaymentMapper paymentMapper;
    private final RedisTemplate<String, String> redisTemplate;
    private final MomoService momoService;
    private final MomoUtil momoUtil;
    private final MomoConfiguration momoConfiguration;
    private final VNPayService vnPayService;
    private final VNPayUtil vnPayUtil;
    private final VNPayConfig vnPayConfig;
    private final BookingOrderService bookingOrderService;
    private final BookingOrderRepository bookingOrderRepository;

    @Value("${booking.compMakeOrderPrefixKey}")
    private String compMakeOrderPrefixKey;
    @Value("${booking.paymentExpirationTime}")
    private int paymentExpirationTime;
    @Value("${booking.paymentPrefixKey}")
    private String paymentPrefixKey;
    @Value("${booking.holdingSeatTime}")
    private int holdingSeatTime;
    @Value("${booking.customerHoldingSeatPrefixKey}")
    private String customerHoldingSeatPrefixKey;

    public Payment createPayment(PaymentRequest request){
        Payment payment = paymentMapper.toPayment(request);
        payment.setUpdatedAt(LocalDateTime.now());
        payment.setStatus(PaymentEnum.PENDING.name());
        BookingOrder bookingOrder = bookingOrderRepository.findById(request.getBookingOrderId())
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        payment.setBookingOrder(bookingOrder);
        return paymentRepository.save(payment);
    }
    public PaymentUrlResponse getPayUrlForCustomer(String paymentId){
        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        // chặn khi customer yêu cầu thanh toán cho 1 payment đã thành công
        if(payment.getStatus().equals(PaymentEnum.SUCCESSFUL.name())) throw new MyAppException(ErrorCode.PAYMENT_COMPLETED);
        Trip trip = payment.getBookingOrder().getTrip();
        if( !trip.getStatus().equals(TripStatusEnum.OPEN.name()))
            throw new MyAppException(ErrorCode.TRIP_NOT_OPEN);
        String payUrl = redisTemplate.opsForValue().get(paymentPrefixKey + paymentId);
        if(payUrl == null){
            // nếu đã bị xóa trong redis -> query lại momo lấy link thanh toán
            String bookingOrderId = payment.getBookingOrder().getId();
            MomoPaymentRequest momoPaymentRequest = MomoPaymentRequest.builder()
                    .bookingOrderId(bookingOrderId)
                    .paymentId(payment.getId())
                    .orderInfo("Thanh toán hóa đơn #" + bookingOrderId)
                    .build();
            MomoPaymentResponse response = momoService.createMomoPayment(momoPaymentRequest, AccountType.COMPANY);
            redisTemplate.opsForValue().set(paymentPrefixKey + payment.getId(), response.getPayUrl(),
                    Duration.ofSeconds(paymentExpirationTime));
            payUrl = response.getPayUrl();
        }
        if(payUrl == null) throw new MyAppException(ErrorCode.PAYMENT_INVALID);
        return PaymentUrlResponse.builder()
                .payUrl(payUrl)
                .build();
    }

    @Transactional
    public Boolean handleMomoIpn(Map<String, Object> payload){
        String resultCode = payload.get("resultCode").toString();
        String momoOrderId = payload.get("orderId").toString();
        ExtraDataDTO extraDataDTO = momoUtil.parseExtraData(payload.get("extraData").toString());
        boolean result = false;
        if( !momoUtil.verifySignature(payload, momoConfiguration.getSecretKey()))
            throw new MyAppException(ErrorCode.ERROR_SIGNATURE);
        if ("0".equals(resultCode)) {
            System.out.println("thanh cong");
            result = true;
        }
        else{
            throw new MyAppException(ErrorCode.ERROR_MOMO_IPN);
        }
        String type = extraDataDTO.getType();
        String bookingOrderId = extraDataDTO.getBookingOrderId();
        String paymentId = extraDataDTO.getPaymentId();
        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        if(type.equals(AccountType.COMPANY.name())){
            // chưa lưu lịch sử khi thanh toán/refund thành công
            int updatedRow = paymentRepository.updateToSuccess(paymentId);
            // update payment thất bại
            if(updatedRow != 1){
                String currentMomoOrderId = payment.getMomoOrderId();
                // nếu momoOrderId khác với DB --> không phải retry payment --> refund
                if( !momoOrderId.equals(currentMomoOrderId)){
                    Long amount = Long.valueOf(payload.get("amount").toString());
                    Long parentTransId = Long.valueOf(payload.get("transId").toString());
                    String description = "Hoàn tiền cho thanh toán hóa đơn #" + bookingOrderId;

                    boolean refundResult = refundPayment(parentTransId, bookingOrderId, amount, description);
                    if(!refundResult) throw new MyAppException(ErrorCode.ERROR_MOMO_REFUND);
                }
                else{
                    log.info("Lỗi ipn trùng cho cùng 1 đơn thanh toán và không có refund");
                }
            }
            else{
                payment.setMomoOrderId(momoOrderId);
                payment.setTransId(Long.valueOf(payload.get("transId").toString()));
                payment.setUpdatedAt(LocalDateTime.now());
                payment.setStatus(PaymentEnum.SUCCESSFUL.name());
                paymentRepository.save(payment);
            }
            bookingOrderService.paymentSuccessfully(bookingOrderId);
        }
        else if(type.equals(AccountType.CUSTOMER.name())){
            boolean refunded = false;
            String customerId = payment.getBookingOrder().getBookingUser() != null
                    ? payment.getBookingOrder().getBookingUser().getId()
                    : null;
            String customerHoldInfo = customerId == null
                    ? null
                    : redisTemplate.opsForValue().get(customerHoldingSeatPrefixKey + customerId);
            long responseTimeMillis = Long.parseLong(payload.get("responseTime").toString());
            LocalDateTime paymentTime = Instant.ofEpochMilli(responseTimeMillis)
                    .atZone(ZoneId.systemDefault()).toLocalDateTime();
            LocalDateTime expiredTime = payment.getBookingOrder().getCreatedAt().plusSeconds(holdingSeatTime);
            boolean missingOrderCodeInRedis = customerHoldInfo == null || !customerHoldInfo.contains(bookingOrderId);
            if (paymentTime.isAfter(expiredTime) || missingOrderCodeInRedis || bookingOrderRepository.isBookingOrderPaid(bookingOrderId)) {
                Long amount = Long.valueOf(payload.get("amount").toString());
                Long parentTransId = Long.valueOf(payload.get("transId").toString());
                String description = missingOrderCodeInRedis
                        ? "Hoàn tiền do không tìm thấy mã đơn hàng trong redis #" + bookingOrderId
                        : "Hoàn tiền cho thanh toán quá hạn hóa đơn #" + bookingOrderId;
                boolean refundResult = refundPayment(parentTransId, bookingOrderId, amount, description);
                if(!refundResult) throw new MyAppException(ErrorCode.ERROR_MOMO_REFUND);
                refunded = true;
            } else {
                int updateRow = paymentRepository.updateToSuccess(paymentId);
                if(updateRow != 1){
                    if (PaymentEnum.SUCCESSFUL.name().equals(payment.getStatus())) {
                        refunded = false;
                    } else {
                        log.info("Refunding payment due to update failure");
                        Long amount = Long.valueOf(payload.get("amount").toString());
                        Long parentTransId = Long.valueOf(payload.get("transId").toString());
                        String description = "Hoàn tiền cho thanh toán hóa đơn #" + bookingOrderId;
                        boolean refundResult = refundPayment(parentTransId, bookingOrderId, amount, description);
                        if(!refundResult) throw new MyAppException(ErrorCode.ERROR_MOMO_REFUND);
                        refunded = true;
                    }
                } else {
                    payment.setMomoOrderId(momoOrderId);
                    payment.setTransId(Long.valueOf(payload.get("transId").toString()));
                    payment.setUpdatedAt(LocalDateTime.now());
                    payment.setStatus(PaymentEnum.SUCCESSFUL.name());
                    payment.setPaymentMethod("MOMO");
                    paymentRepository.save(payment);
                    log.info("Payment successfully processed for booking order: {}", bookingOrderId);
                }
            }
            if (!refunded) {
                bookingOrderService.paymentSuccessfully(bookingOrderId);
            }
        }
        return result;
    }

    public MomoPaymentResponse getMomoQrForCustomer(String paymentId) {
        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        if (payment.getStatus().equals(PaymentEnum.SUCCESSFUL.name())) {
            throw new MyAppException(ErrorCode.PAYMENT_COMPLETED);
        }

        // Validate that current customer owns this payment
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentCustomerId = authentication != null ? authentication.getName() : null;
        if (currentCustomerId == null) {
            throw new MyAppException(ErrorCode.UNAUTHENTICATED);
        }

        String paymentOwnerId = payment.getBookingOrder().getBookingUser().getId();
        if (!currentCustomerId.equals(paymentOwnerId)) {
            throw new MyAppException(ErrorCode.UNAUTHENTICATED);
        }

        String payUrlKey = paymentPrefixKey + paymentId;
        String qrCodeKey = paymentPrefixKey + paymentId + ":qr";
        String payUrl = redisTemplate.opsForValue().get(payUrlKey);
        String qrCodeUrl = redisTemplate.opsForValue().get(qrCodeKey);

        if (payUrl == null || qrCodeUrl == null) {
            String bookingOrderId = payment.getBookingOrder().getId();
            MomoPaymentRequest momoPaymentRequest = MomoPaymentRequest.builder()
                    .bookingOrderId(bookingOrderId)
                    .paymentId(payment.getId())
                    .orderInfo("Thanh toán hóa đơn #" + bookingOrderId)
                    .build();

            MomoPaymentResponse response = momoService.createMomoPayment(momoPaymentRequest, AccountType.CUSTOMER);

            // compute remaining hold time
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime expireTime = payment.getBookingOrder().getCreatedAt().plusSeconds(holdingSeatTime);
            long remainingSeconds = java.time.Duration.between(now, expireTime).getSeconds();
            if (remainingSeconds <= 0) throw new MyAppException(ErrorCode.PAYMENT_INVALID);

            redisTemplate.opsForValue().set(payUrlKey, response.getPayUrl(), Duration.ofSeconds(remainingSeconds));
            redisTemplate.opsForValue().set(qrCodeKey, response.getQrCodeUrl(), Duration.ofSeconds(remainingSeconds));

            payUrl = response.getPayUrl();
            qrCodeUrl = response.getQrCodeUrl();
        }

        if (payUrl == null || qrCodeUrl == null) {
            throw new MyAppException(ErrorCode.PAYMENT_INVALID);
        }

        return MomoPaymentResponse.builder()
                .payUrl(payUrl)
                .qrCodeUrl(qrCodeUrl)
                .build();
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public boolean refundPayment(Long parentTransId, String bookingOrderId, Long amount, String description){
        PaymentRequest paymentRequest = PaymentRequest.builder()
                .parentTransId(parentTransId)
                .bookingOrderId(bookingOrderId)
                .type(MomoEnum.REFUND.name())
                .amount(amount)
                .build();
        Payment refundPayment = createPayment(paymentRequest);
        refundPayment.setPaymentMethod("MOMO");

        MomoRefundRequest momoRefundRequest = MomoRefundRequest.builder()
                .transId(parentTransId)
                .amount(amount)
                .description(description)
                .build();
        MomoRefundResponse momoRefundResponse = momoService.createMomoRefund(momoRefundRequest);
        refundPayment.setTransId(momoRefundResponse.getTransId());
        refundPayment.setMomoOrderId(momoRefundResponse.getMomoOrderId());
        if(momoRefundResponse.getResultCode() == 0) refundPayment.setStatus(PaymentEnum.SUCCESSFUL.name());
        else refundPayment.setStatus(PaymentEnum.FAILED.name());
        paymentRepository.save(refundPayment);
        return refundPayment.getStatus().equals(PaymentEnum.SUCCESSFUL.name());
    }

    // ===========================
    // VNPay payment methods
    // ===========================

    /**
     * Lấy URL thanh toán VNPay cho customer.
     * Key Redis: "payment:vnpay:<paymentId>"
     * TTL = remaining hold time (holdingSeatTime - elapsed time since booking created)
     */
    public VNPayPaymentResponse getVNPayUrlForCustomer(String paymentId, String ipAddress) {
        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        if (payment.getStatus().equals(PaymentEnum.SUCCESSFUL.name()))
            throw new MyAppException(ErrorCode.PAYMENT_COMPLETED);

        Trip trip = payment.getBookingOrder().getTrip();
        if (!trip.getStatus().equals(TripStatusEnum.OPEN.name()))
            throw new MyAppException(ErrorCode.TRIP_NOT_OPEN);

        // Kiểm tra customer sở hữu payment này
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentCustomerId = authentication != null ? authentication.getName() : null;
        if (currentCustomerId == null) throw new MyAppException(ErrorCode.UNAUTHENTICATED);

        String paymentOwnerId = payment.getBookingOrder().getBookingUser() != null
                ? payment.getBookingOrder().getBookingUser().getId() : null;
        if (!currentCustomerId.equals(paymentOwnerId))
            throw new MyAppException(ErrorCode.UNAUTHENTICATED);

        String cacheKey = paymentPrefixKey + "vnpay:" + paymentId;
        String cachedUrl = redisTemplate.opsForValue().get(cacheKey);
        if (cachedUrl != null) {
            return VNPayPaymentResponse.builder().payUrl(cachedUrl).build();
        }

        String bookingOrderId = payment.getBookingOrder().getId();
        VNPayPaymentRequest vnPayRequest = VNPayPaymentRequest.builder()
                .bookingOrderId(bookingOrderId)
                .paymentId(payment.getId())
                .orderInfo("Thanh toan hoa don #" + bookingOrderId)
                .build();

        VNPayPaymentResponse response = vnPayService.createVNPayPayment(vnPayRequest, AccountType.CUSTOMER, ipAddress);

        // compute remaining hold time and cache VNPay url accordingly
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime expireTime = payment.getBookingOrder().getCreatedAt().plusSeconds(holdingSeatTime);
        long remainingSeconds = java.time.Duration.between(now, expireTime).getSeconds();
        if (remainingSeconds <= 0) throw new MyAppException(ErrorCode.PAYMENT_INVALID);

        redisTemplate.opsForValue().set(cacheKey, response.getPayUrl(), Duration.ofSeconds(remainingSeconds));
        return response;
    }

    /**
     * Create a Payment record (PENDING) for a booking order. Used when payment wasn't created during hold.
     */
    public Payment createPaymentForBooking(String bookingOrderId) {
        BookingOrder bookingOrder = bookingOrderRepository.findById(bookingOrderId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));
        PaymentRequest paymentRequest = PaymentRequest.builder()
                .amount(bookingOrder.getTotalCost())
                .bookingOrderId(bookingOrderId)
                .type(MomoEnum.PAYMENT.name())
                .build();
        return createPayment(paymentRequest);
    }

    /**
     * Xử lý IPN callback từ VNPay (GET query params).
     * vnp_TxnRef = paymentId → tra cứu Payment trực tiếp.
     */
    @Transactional
    public Boolean handleVNPayIpn(Map<String, String> params) {
        // Xác thực chữ ký
        if (!vnPayUtil.verifySignature(params, vnPayConfig.getHashSecret())) {
            throw new MyAppException(ErrorCode.ERROR_SIGNATURE);
        }

        String responseCode = params.get("vnp_ResponseCode");
        String paymentId = params.get("vnp_TxnRef");   // = paymentId
        String transactionNo = params.get("vnp_TransactionNo");
        String amountStr = params.get("vnp_Amount");    // đơn vị × 100

        if (paymentId == null) throw new MyAppException(ErrorCode.ERROR_VNPAY_IPN);

        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new MyAppException(ErrorCode.NOT_EXISTED));

        String bookingOrderId = payment.getBookingOrder().getId();

        if (!"00".equals(responseCode)) {
            log.warn("VNPay IPN failed: responseCode={}, paymentId={}", responseCode, paymentId);
            throw new MyAppException(ErrorCode.ERROR_VNPAY_IPN);
        }

        // Kiểm tra hết hạn thanh toán
        String customerId = payment.getBookingOrder().getBookingUser() != null
                ? payment.getBookingOrder().getBookingUser().getId() : null;
        String customerHoldInfo = customerId == null
                ? null
                : redisTemplate.opsForValue().get(customerHoldingSeatPrefixKey + customerId);

        long responseTimeMillis = System.currentTimeMillis(); // VNPay IPN không trả vnp_PayDate qua GET chuẩn
        LocalDateTime paymentTime = LocalDateTime.now();
        LocalDateTime expiredTime = payment.getBookingOrder().getCreatedAt().plusSeconds(holdingSeatTime);
        boolean missingOrderCodeInRedis = customerHoldInfo == null || !customerHoldInfo.contains(bookingOrderId);

        boolean refunded = false;
        Long amount = amountStr != null ? Long.parseLong(amountStr) / 100L : 0L;

        if (paymentTime.isAfter(expiredTime) || missingOrderCodeInRedis || bookingOrderRepository.isBookingOrderPaid(bookingOrderId)) {
            String description = missingOrderCodeInRedis
                    ? "Hoan tien do khong tim thay ma don hang #" + bookingOrderId
                    : "Hoan tien thanh toan qua han hoa don #" + bookingOrderId;
            boolean refundResult = refundVNPayPayment(paymentId, bookingOrderId, amount,
                    transactionNo, description);
            if (!refundResult) throw new MyAppException(ErrorCode.ERROR_VNPAY_REFUND);
            refunded = true;
        } else {
            int updatedRow = paymentRepository.updateToSuccess(paymentId);
            if (updatedRow != 1) {
                if (PaymentEnum.SUCCESSFUL.name().equals(payment.getStatus())) {
                    log.info("VNPay IPN duplicate for paymentId={}", paymentId);
                } else {
                    String description = "Hoan tien thanh toan hoa don #" + bookingOrderId;
                    boolean refundResult = refundVNPayPayment(paymentId, bookingOrderId, amount,
                            transactionNo, description);
                    if (!refundResult) throw new MyAppException(ErrorCode.ERROR_VNPAY_REFUND);
                    refunded = true;
                }
            } else {
                payment.setVnpayOrderId(paymentId);
                payment.setTransId(Long.parseLong(transactionNo));
                payment.setPaymentMethod("VNPAY");
                payment.setUpdatedAt(LocalDateTime.now());
                payment.setStatus(PaymentEnum.SUCCESSFUL.name());
                paymentRepository.save(payment);
                log.info("VNPay payment successful: paymentId={}, transactionNo={}", paymentId, transactionNo);
            }
        }

        if (!refunded) {
            bookingOrderService.paymentSuccessfully(bookingOrderId);
        }
        return true;
    }

    /**
     * Hoàn tiền qua VNPay (tạo Payment refund record + gọi API VNPay)
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public boolean refundVNPayPayment(String originalPaymentId, String bookingOrderId,
                                      Long amount, String transactionNo, String description) {
        PaymentRequest paymentRequest = PaymentRequest.builder()
                .bookingOrderId(bookingOrderId)
                .type(MomoEnum.REFUND.name())
                .amount(amount)
                .build();
        Payment refundPayment = createPayment(paymentRequest);
        refundPayment.setPaymentMethod("VNPAY");
        try {
            VNPayRefundResponse refundResponse = vnPayService.createVNPayRefund(
                    originalPaymentId, amount, transactionNo, description, "127.0.0.1");

            refundPayment.setVnpayOrderId(refundResponse.getTransactionNo());
            if ("00".equals(refundResponse.getResponseCode())) {
                refundPayment.setStatus(PaymentEnum.SUCCESSFUL.name());
            } else {
                refundPayment.setStatus(PaymentEnum.FAILED.name());
                log.error("VNPay refund failed: code={}, message={}", refundResponse.getResponseCode(), refundResponse.getMessage());
            }
            paymentRepository.save(refundPayment);
            return refundPayment.getStatus().equals(PaymentEnum.SUCCESSFUL.name());
        } catch (MyAppException e) {
            // ensure refund record persisted with FAILED status and log root cause
            refundPayment.setStatus(PaymentEnum.FAILED.name());
            paymentRepository.save(refundPayment);
            log.error("Exception while calling VNPay refund API for paymentId={}, bookingOrderId={}: {}", originalPaymentId, bookingOrderId, e.getMessage(), e);
            return false;
        } catch (Exception e) {
            refundPayment.setStatus(PaymentEnum.FAILED.name());
            paymentRepository.save(refundPayment);
            log.error("Unexpected error while refunding VNPay paymentId={}, bookingOrderId={}: {}", originalPaymentId, bookingOrderId, e.getMessage(), e);
            return false;
        }
    }
}
