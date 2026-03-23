import React from 'react';
import HeaderStyle from "./Header.module.css"


const Header = () => {
  return (
    <header className={`${HeaderStyle["header-container"]}`}>
        <div className={`${HeaderStyle["header-content"]}`}>
            {/* Khối bên trái: Logo và Cam kết */}
            <div className={`${HeaderStyle["header-left"]}`}>
                <div className={`${HeaderStyle["logo"]}`}>
                    <span className={`${HeaderStyle["bus-icon"]}`}>🚌</span>
                    <span className={`${HeaderStyle["brand-name"]}`}>vexere</span>
                </div>
                <p className={`${HeaderStyle["slogan"]}`}>
                    Cam kết hoàn 150% nếu nhà xe <br />
                    không cung cấp dịch vụ vận chuyển (*) ⓘ
                </p>
            </div>

            {/* Khối bên phải: Menu điều hướng */}
            <nav className={`${HeaderStyle["header-right"]}`}>
                <a href="#">Mở bán vé trên Vexere</a>
                <a href="#">Đơn hàng của tôi</a>
                
                <div className={`${HeaderStyle["help-icon"]}`}>❓</div>
                <button className={`${HeaderStyle["hotline-btn"]}`}>📞 Hotline 24/7</button>
                <button className={`${HeaderStyle["login-btn"]}`}>Đăng nhập</button>
            </nav>
        </div>
    </header>
  );
};

export default Header;