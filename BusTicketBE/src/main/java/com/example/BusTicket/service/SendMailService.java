package com.example.BusTicket.service;

import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.Payment;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SendMailService {
    private final MailService mailService; // Inject MailService bạn đã viết
    private final MomoService momoService;

    public void sendCredentials(String employeeEmail, String password, String companyName) {
        // 1. Tạo mật khẩu ngẫu nhiên (Lấy 8 ký tự đầu của UUID)
        if(companyName == null) companyName = "VEXEDAT";
        String htmlBody = """
            <html>
            <body style="font-family: sans-serif;">
                <h3>Thông tin tài khoản nhân viên</h3>
                <p>Email: <b>%s</b></p>
                <p>Mật khẩu tạm thời: <b>%s</b></p>
                <p>Vui lòng đổi mật khẩu sau khi đăng nhập.</p>
            </body>
            </html>
            """.formatted(employeeEmail, password);

        // 3. Gửi mail sử dụng hàm sendHtmlMail bạn đã có
        mailService.sendHtmlMail(
                employeeEmail,
                companyName + " cấp tài khoản nhân viên mới",
                htmlBody,
                null,
                null
        );
    }

    public void sendBookingPaymentEmail(BookingOrder bookingOrder, Payment payment) {
        BusCompany busCompany = bookingOrder.getTrip().getBusCompany();
        String companyName = (busCompany != null ? busCompany.getCompanyName() : "VEXEDAT");

        // Tạo link dẫn tới trang thanh toán
        String paymentUrl = "http://localhost:5173/redirect-momo/payment/" + payment.getId();
        String[] time = bookingOrder.getTrip().getDepartureTime().toString().split("T");
        String htmlBody = """
        <html>
        <body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; background-color: #f4f4f4; padding: 20px;">
            <div style="max-width: 500px; margin: 0 auto; background: #ffffff; padding: 30px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.1);">
                <h2 style="color: #007bff; text-align: center; margin-top: 0;">Xác Nhận Đặt Vé</h2>
                <p>Chào <b>%s</b>,</p>
                <p>Cảm ơn bạn đã đặt vé tại <b>%s</b>. Dưới đây là thông tin thanh toán cho đơn hàng của bạn:</p>
                
                <div style="background: #f9f9f9; border-left: 4px solid #007bff; padding: 15px; margin: 20px 0;">
                    <p style="margin: 5px 0;"><b>Mã đơn hàng:</b> #%s</p>
                    <p style="margin: 5px 0;"><b>Lộ trình:</b> %s &rarr; %s</p>
                    <p style="margin: 5px 0;"><b>Thời gian:</b> %s </p>
                    <p style="margin: 5px 0;"><b>Tổng tiền:</b> <span style="color: #e74c3c; font-weight: bold; font-size: 1.2em;">%d VNĐ</span></p>
                </div>

                <div style="text-align: center; margin-top: 30px;">
                    <a href="%s" style="background-color: #27ae60; color: white; padding: 12px 25px; text-decoration: none; border-radius: 5px; font-weight: bold; display: inline-block;">
                        THANH TOÁN NGAY
                    </a>
                </div>
                

            </div>
        </body>
        </html>
        """.formatted(
                bookingOrder.getCustomerName(),
                companyName,
                bookingOrder.getId(),
                bookingOrder.getTrip().getRoute().getArrivalProvince().getName(),
                bookingOrder.getTrip().getRoute().getDestinationProvince().getName(),
                time[1] + " " + time[0],
                bookingOrder.getTotalCost(),
                paymentUrl
        );
//                <p style="font-size: 0.9em; color: #777; margin-top: 30px; text-align: center;">
//                <i>Lưu ý: Liên kết thanh toán này sẽ hết hạn sau 30 phút.</i>
//                </p>
        mailService.sendHtmlMail(
                bookingOrder.getCustomerEmail(),
                "[" + companyName + "] Thông tin thanh toán đơn hàng #" + bookingOrder.getId(),
                htmlBody,
                null,
                null
        );
    }
}
