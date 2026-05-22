package com.example.BusTicket.service;

import com.example.BusTicket.entity.BookingOrder;
import com.example.BusTicket.entity.BusCompany;
import com.example.BusTicket.entity.Payment;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.text.NumberFormat;
import java.util.Locale;
import com.example.BusTicket.entity.Ticket;

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

    public void sendCustomerPaymentSuccessEmail(BookingOrder bookingOrder, List<Ticket> tickets) {
        if (bookingOrder == null || bookingOrder.getCustomerEmail() == null || bookingOrder.getCustomerEmail().isBlank()) {
            return;
        }

        BusCompany busCompany = bookingOrder.getTrip().getBusCompany();
        String companyName = (busCompany != null ? busCompany.getCompanyName() : "VEXEDAT");
        NumberFormat currencyFormatter = NumberFormat.getInstance(new Locale("vi", "VN"));
        String[] tripDateTime = bookingOrder.getTrip().getDepartureTime().toString().split("T");
        String seatInfo = tickets.stream()
                .map(ticket -> ticket.getTripSeat().getSeat())
                .sorted()
                .reduce((left, right) -> left + ", " + right)
                .orElse("N/A");
        String pickupPoint = tickets.stream()
                .map(ticket -> ticket.getArrival())
                .filter(routeStop -> routeStop != null && routeStop.getStop() != null)
                .map(routeStop -> routeStop.getStop().getName())
                .findFirst()
                .orElse("Chưa xác định");
        String dropoffPoint = tickets.stream()
                .map(ticket -> ticket.getDestination())
                .filter(routeStop -> routeStop != null && routeStop.getStop() != null)
                .map(routeStop -> routeStop.getStop().getName())
                .findFirst()
                .orElse("Chưa xác định");

        String htmlBody = """
        <html>
        <body style="margin:0;padding:0;background:linear-gradient(135deg,#edf7ff 0%%,#f8faff 100%%);font-family:'Segoe UI',Tahoma,Verdana,sans-serif;color:#243447;">
            <div style="max-width:620px;margin:28px auto;padding:0 14px;">
                <div style="background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 10px 30px rgba(31, 74, 140, 0.15);">
                    <div style="background:linear-gradient(90deg,#1cbf73,#159957);padding:22px 28px;color:#fff;">
                        <h2 style="margin:0;font-size:26px;">✅ Thanh toán thành công</h2>
                        <p style="margin:8px 0 0;font-size:14px;opacity:0.95;">Cảm ơn bạn đã tin tưởng đặt vé tại <b>%s</b>.</p>
                    </div>

                    <div style="padding:24px 28px 6px;">
                        <p style="margin:0 0 14px;font-size:15px;">Xin chào <b>%s</b>, hệ thống đã ghi nhận thanh toán thành công cho đơn hàng của bạn.</p>

                        <table style="width:100%%;border-collapse:separate;border-spacing:0 10px;font-size:14px;">
                            <tr><td style="width:42%%;color:#6b7785;">Mã đơn hàng</td><td style="font-weight:700;">#%s</td></tr>
                            <tr><td style="color:#6b7785;">Khách hàng</td><td>%s</td></tr>
                            <tr><td style="color:#6b7785;">Số điện thoại</td><td>%s</td></tr>
                            <tr><td style="color:#6b7785;">Email</td><td>%s</td></tr>
                            <tr><td style="color:#6b7785;">Lộ trình</td><td>%s → %s</td></tr>
                            <tr><td style="color:#6b7785;">Điểm đón</td><td>%s</td></tr>
                            <tr><td style="color:#6b7785;">Điểm trả</td><td>%s</td></tr>
                            <tr><td style="color:#6b7785;">Thời gian khởi hành</td><td>%s %s</td></tr>
                            <tr><td style="color:#6b7785;">Số ghế</td><td>%s</td></tr>
                            <tr><td style="color:#6b7785;">Số lượng vé</td><td>%d</td></tr>
                            <tr><td style="color:#6b7785;">Tổng tiền</td><td style="font-size:17px;font-weight:700;color:#d94727;">%s VNĐ</td></tr>
                        </table>

                        <div style="margin:16px 0 8px;padding:12px 14px;background:#f4f9ff;border-left:4px solid #4aa3ff;border-radius:8px;font-size:13px;color:#51606f;">
                            Vui lòng có mặt tại điểm đón trước giờ khởi hành để chuyến đi thuận lợi.
                        </div>
                    </div>

                    <div style="padding:14px 28px 20px;color:#7b8794;font-size:12px;text-align:center;border-top:1px solid #eef2f7;">
                        Chúc bạn có chuyến đi an toàn và thoải mái cùng %s 💚
                    </div>
                </div>
            </div>
        </body>
        </html>
        """.formatted(
                companyName,
                bookingOrder.getCustomerName(),
                bookingOrder.getId(),
                bookingOrder.getCustomerName(),
                bookingOrder.getCustomerPhone(),
                bookingOrder.getCustomerEmail(),
                bookingOrder.getTrip().getRoute().getArrivalProvince().getName(),
                bookingOrder.getTrip().getRoute().getDestinationProvince().getName(),
                pickupPoint,
                dropoffPoint,
                tripDateTime[1],
                tripDateTime[0],
                seatInfo,
                tickets.size(),
                currencyFormatter.format(bookingOrder.getTotalCost()),
                companyName
        );

        mailService.sendHtmlMail(
                bookingOrder.getCustomerEmail(),
                "[" + companyName + "] Xác nhận thanh toán thành công #" + bookingOrder.getId(),
                htmlBody,
                null,
                null
        );
    }
}
