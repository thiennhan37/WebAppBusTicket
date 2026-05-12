package com.example.BusTicket.service;

import com.example.BusTicket.configuration.MomoConfiguration;
import com.example.BusTicket.dto.general.ExtraDataDTO;
import com.example.BusTicket.dto.request.MomoPaymentRequest;
import com.example.BusTicket.dto.request.MomoRefundRequest;
import com.example.BusTicket.dto.request.PaymentRequest;
import com.example.BusTicket.dto.response.MomoPaymentResponse;
import com.example.BusTicket.dto.response.MomoRefundResponse;
import com.example.BusTicket.dto.response.PaymentResponse;
import com.example.BusTicket.dto.response.PaymentUrlResponse;
import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.entity.Payment;
import com.example.BusTicket.enums.MomoEnum;
import com.example.BusTicket.enums.PaymentEnum;
import com.example.BusTicket.exception.ErrorCode;
import com.example.BusTicket.exception.MyAppException;
import com.example.BusTicket.mapper.PaymentMapper;
import com.example.BusTicket.repository.jpa.BookingOrderRepository;
import com.example.BusTicket.repository.jpa.PaymentRepository;
import com.example.BusTicket.util.MomoUtil;
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
    private final BookingOrderService bookingOrderService;

    @Value("${booking.paymentExpirationTime}")
    private int paymentExpirationTime;
    @Value("${booking.paymentPrefixKey}")
    private String paymentPrefixKey;
    private final BookingOrderRepository bookingOrderRepository;

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

        String payUrl = redisTemplate.opsForValue().get(paymentPrefixKey + paymentId);
        if(payUrl == null){
            // nếu đã bị xóa tỏng redis -> query lại momo lấy link thanh toán
            String bookingOrderId = payment.getBookingOrder().getId();
            MomoPaymentRequest momoPaymentRequest = MomoPaymentRequest.builder()
                    .bookingOrderId(bookingOrderId)
                    .paymentId(payment.getId())
                    .orderInfo("Thanh toán hóa đơn #" + bookingOrderId)
                    .build();
            MomoPaymentResponse response = momoService.createMomoPayment(momoPaymentRequest);
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
        if(type.equals(MomoEnum.PAYMENT.name())){
            // chưa lưu lịch sử khi thanh toán/refund thành công
            log.info("xử lí payment");
            int updatedRow = paymentRepository.updateToSuccess(paymentId);
            // update payment thất bại
            if(updatedRow != 1){
                log.info("cập nhật payment thất bại");
                String currentMomoOrderId = payment.getMomoOrderId();
                // nếu momoOrderId khác với DB --> không phải retry payment --> refund
                if( !momoOrderId.equals(currentMomoOrderId)){
                    log.info("thực hiện refund");
                    Long amount = Long.valueOf(payload.get("amount").toString());
                    Long parentTransId = Long.valueOf(payload.get("transId").toString());
                    String description = "Hoàn tiền cho thanh toán hóa đơn #" + bookingOrderId;

                    boolean refundResult = refundPayment(parentTransId, bookingOrderId, amount, description);
                    if(!refundResult) throw new MyAppException(ErrorCode.ERROR_MOMO_REFUND);
                }
                else{
                    log.info("Thanh toán trùng lặp và không có refund");
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
        else if(type.equals(MomoEnum.REFUND.name()) ){
            System.out.println("refund ticket service");
        }
        else{
            System.out.println("co loi extraData");
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

            MomoPaymentResponse response = momoService.createMomoPayment(momoPaymentRequest);
            redisTemplate.opsForValue().set(payUrlKey, response.getPayUrl(), Duration.ofSeconds(paymentExpirationTime));
            redisTemplate.opsForValue().set(qrCodeKey, response.getQrCodeUrl(), Duration.ofSeconds(paymentExpirationTime));

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
}
