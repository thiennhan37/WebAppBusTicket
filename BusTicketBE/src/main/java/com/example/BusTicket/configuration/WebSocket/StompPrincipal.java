package com.example.BusTicket.configuration.WebSocket;

import java.security.Principal;

// bản thân stomp cho websocket không có cơ chế xác thực
// nên chúng ta sẽ tự tạo một class để lưu thông tin người dùng khi kết nối websocket,
// sau đó sẽ lấy thông tin này để xác thực quyền truy cập vào các topic
public class StompPrincipal implements Principal {

    private final String userId;
    private final String role;

    public StompPrincipal(
            String userId,
            String role
    ) {
        this.userId = userId;
        this.role = role;
    }

    @Override
    public String getName() {
        return userId;
    }

    public String getRole() {
        return role;
    }
}
