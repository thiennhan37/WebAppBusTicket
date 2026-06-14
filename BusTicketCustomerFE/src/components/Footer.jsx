import { Link } from "react-router-dom";
import { Phone, Mail, MapPin } from "lucide-react";
import "./Footer.css";

export default function Footer() {
  return (
    <footer className="footer">
      <div className="footer__inner">
        <div className="footer__grid">
          <div>
            <div className="footer__brand-name">
              Vé Xe<span>Đắt</span>
            </div>
            <p className="footer__brand-desc">
              Hệ thống đặt vé xe khách trực tuyến. Cam kết hoàn tiền nếu nhà xe
              không cung cấp dịch vụ vận chuyển.
            </p>
          </div>

          <div>
            <div className="footer__section-title">Hỗ trợ</div>
            <Link to="/khachhang" className="footer__link">Hướng dẫn đặt vé</Link>
            <Link to="/khachhang" className="footer__link">Chính sách hoàn vé</Link>
            <Link to="/khachhang" className="footer__link">Câu hỏi thường gặp</Link>
            <Link to="/khachhang" className="footer__link">Điều khoản sử dụng</Link>
          </div>

          <div>
            <div className="footer__section-title">Khám phá</div>
            <Link to="/khachhang" className="footer__link">Tuyến phổ biến</Link>
            <Link to="/khachhang" className="footer__link">Nhà xe uy tín</Link>
            <Link to="/khachhang" className="footer__link">Khuyến mãi</Link>
            <Link to="/khachhang" className="footer__link">Blog du lịch</Link>
          </div>

          <div>
            <div className="footer__section-title">Liên hệ</div>
            <div className="footer__link">
              <Phone size={12} style={{ display: "inline", marginRight: 6 }} />
              1900 0000
            </div>
            <div className="footer__link">
              <Mail size={12} style={{ display: "inline", marginRight: 6 }} />
              support@vexedat.vn
            </div>
            <div className="footer__link">
              <MapPin size={12} style={{ display: "inline", marginRight: 6 }} />
              TP. Hồ Chí Minh
            </div>
          </div>
        </div>

        <div className="footer__bottom">
          <div className="footer__copyright">
            © 2026 Vé Xe Đắt — All rights reserved
          </div>
          <div className="footer__tagline">Built with Brutalism ■</div>
        </div>
      </div>
    </footer>
  );
}
