package com.example.BusTicket.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AccountMailService {
    private final MailService mailService; // Inject MailService bạn đã viết

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
}
