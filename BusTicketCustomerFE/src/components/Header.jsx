import { useState } from "react";
import { Link, useLocation } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { Bus, LogOut, Menu, X, User, ClipboardList, Heart, Bell } from "lucide-react";
import "./Header.css";

export default function Header() {
  const { user, isAuthenticated, logout } = useAuth();
  const location = useLocation();
  const [mobileOpen, setMobileOpen] = useState(false);

  const isHomePage = location.pathname === "/khachhang";

  const renderUserActions = (onNavigate) =>
    isAuthenticated ? (
      <>
        <span className="header__user-name">{user?.fullName || user?.email}</span>
        <button className="header__logout-btn" onClick={logout} title="Đăng xuất">
          <LogOut size={16} />
        </button>
      </>
    ) : (
      <>
        <Link
          to="/khachhang/dang-nhap"
          className="header__login-btn"
          onClick={onNavigate}
        >
          Đăng nhập
        </Link>
        <Link
          to="/khachhang/dang-ky"
          className="header__register-btn"
          onClick={onNavigate}
        >
          Đăng ký
        </Link>
      </>
    );

  const navLinks = [
    {
      path: "/khachhang/don-hang",
      label: "Đơn hàng của tôi",
      icon: <ClipboardList size={14} />,
    },
    {
      path: "/khachhang/yeu-thich",
      label: "Yêu thích",
      icon: <Heart size={14} />,
      auth: true,
    },
    {
      path: "/khachhang/thong-bao",
      label: "Thông báo",
      icon: <Bell size={14} />,
      auth: true,
    },
    {
      path: "/khachhang/tai-khoan",
      label: "Tài khoản",
      icon: <User size={14} />,
      auth: true,
    },
  ];

  return (
    <header className="header">
      <div className="header__inner">
        {/* Logo */}
        <Link to="/khachhang" className="header__logo">
          <div className="header__logo-icon">
            <Bus size={22} color="#000" />
          </div>
          <div className="header__logo-text">
            VeXe<span>Dat</span>
          </div>
        </Link>

        {/* Mobile toggle */}
        <button
          className="header__mobile-toggle"
          onClick={() => setMobileOpen(!mobileOpen)}
          aria-label="Toggle menu"
        >
          {mobileOpen ? <X size={24} /> : <Menu size={24} />}
        </button>

        {/* Nav links */}
        <nav className={`header__nav ${mobileOpen ? "header__nav--open" : ""}`}>
          {navLinks.map((link) => {
            if (link.auth && !isAuthenticated) return null;
            return (
              <Link
                key={link.path}
                to={link.path}
                className={`header__nav-link ${
                  location.pathname === link.path ? "header__nav-link--active" : ""
                }`}
                onClick={() => setMobileOpen(false)}
              >
                {link.icon}
                {link.label}
              </Link>
            );
          })}

          <div className="header__user-menu-mobile">
            {renderUserActions(() => setMobileOpen(false))}
          </div>
        </nav>

        <div className="header__user-menu">
          {renderUserActions()}
        </div>
      </div>
    </header>
  );
}
