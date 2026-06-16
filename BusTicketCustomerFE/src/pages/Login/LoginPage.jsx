import React, { useState, useEffect } from "react";
import { useNavigate, useSearchParams, Link } from "react-router-dom";
import { useAuth } from "../../context/AuthContext";
import { sendOtp, verifyOtp, getGoogleLoginUrl, googleCallback } from "../../services/authService";
import BrutalCard from "../../components/BrutalCard";
import BrutalButton from "../../components/BrutalButton";
import BrutalInput from "../../components/BrutalInput";
import { Mail, ShieldCheck, LogIn } from "lucide-react";
import { toast } from "sonner";
import "./LoginPage.css";

export default function LoginPage() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const { login, isAuthenticated } = useAuth();

  const redirectUrl = searchParams.get("redirect") || "/khachhang";
  const oauthCode = searchParams.get("code");

  const [email, setEmail] = useState("");
  const [otp, setOtp] = useState("");
  const [step, setStep] = useState(1); // 1: Email Input, 2: OTP Input
  const [loading, setLoading] = useState(false);
  const [oauthLoading, setOauthLoading] = useState(false);

  // Handle OAuth Google Redirect callback
  useEffect(() => {
    if (oauthCode) {
      const handleGoogleCallback = async () => {
        setOauthLoading(true);
        try {
          const res = await googleCallback(oauthCode);
          const { customerInfo, accessToken, refreshToken } = res.data.result || res.data;
          login(customerInfo, accessToken, refreshToken);
          toast.success("Đăng nhập bằng Google thành công!");
          navigate(redirectUrl);
        } catch (err) {
          console.error("Google login callback error:", err);
          toast.error("Đăng nhập bằng Google thất bại. Vui lòng thử lại!");
        } finally {
          setOauthLoading(false);
        }
      };
      handleGoogleCallback();
    }
  }, [oauthCode]);

  useEffect(() => {
    if (isAuthenticated && !oauthCode) {
      navigate(redirectUrl);
    }
  }, [isAuthenticated, navigate, redirectUrl, oauthCode]);

  const handleSendOtp = async (e) => {
    e.preventDefault();
    if (!email) return;

    setLoading(true);
    try {
      await sendOtp(email);
      toast.success("Mã OTP đã được gửi đến email của bạn.");
      setStep(2);
    } catch (err) {
      console.error("Send OTP error:", err);
      const msg = err.response?.data?.message || "Không thể gửi OTP. Vui lòng kiểm tra lại email!";
      toast.error(msg);
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOtp = async (e) => {
    e.preventDefault();
    if (!otp) return;

    setLoading(true);
    try {
      const res = await verifyOtp(email, otp);
      const { customerInfo, accessToken, refreshToken } = res.data.result || res.data;
      
      login(customerInfo, accessToken, refreshToken);
      toast.success("Đăng nhập thành công!");
      navigate(redirectUrl);
    } catch (err) {
      console.error("Verify OTP error:", err);
      toast.error("Mã OTP không hợp lệ hoặc đã hết hạn!");
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleLogin = async () => {
    try {
      const res = await getGoogleLoginUrl();
      const googleUrl = res.data.result || res.data;
      if (googleUrl) {
        window.location.href = googleUrl;
      } else {
        throw new Error("Không thể khởi tạo đường dẫn Google đăng nhập");
      }
    } catch (err) {
      console.error("Google URL initiation error:", err);
      toast.error("Lỗi đăng nhập bằng Google!");
    }
  };

  if (oauthLoading) {
    return (
      <div className="login-page">
        <div className="container">
          <div className="page-loader">
            <div className="brutal-spinner"></div>
            <p>Đang xác thực tài khoản Google...</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="login-page">
      <div className="container">
        <BrutalCard className="login-card" noHover>
          <div className="login-card__header">
            <h2 className="login-card__title">Đăng nhập tài khoản</h2>
            <p className="login-card__subtitle">Dành cho khách hàng sử dụng dịch vụ Vé Xe Đắt</p>
          </div>

          {step === 1 ? (
            <form onSubmit={handleSendOtp}>
              <BrutalInput
                label="Địa chỉ Email"
                id="login-email"
                type="email"
                placeholder="Gmail với đuôi @gmail.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />

              <BrutalButton
                type="submit"
                variant="primary"
                size="large"
                className="brutal-btn--full"
                disabled={loading}
              >
                {loading ? "ĐANG GỬI MÃ..." : "NHẬN MÃ ĐĂNG NHẬP (OTP)"}
              </BrutalButton>
            </form>
          ) : (
            <form onSubmit={handleVerifyOtp}>
              <div className="otp-intro-alert text-mono">
                Mã OTP đã được gửi đến email: <br />
                <strong>{email}</strong>
              </div>

              <BrutalInput
                label="Nhập mã OTP"
                id="login-otp"
                type="text"
                placeholder="Nhập 6 ký tự OTP..."
                value={otp}
                onChange={(e) => setOtp(e.target.value)}
                required
              />

              <div className="otp-actions-row">
                <button
                  type="button"
                  className="back-step-btn text-mono"
                  onClick={() => setStep(1)}
                  disabled={loading}
                >
                  Thay đổi Email
                </button>
              </div>

              <BrutalButton
                type="submit"
                variant="primary"
                size="large"
                className="brutal-btn--full"
                disabled={loading}
              >
                {loading ? "ĐANG XÁC THỰC..." : "XÁC NHẬN ĐĂNG NHẬP"}
              </BrutalButton>
            </form>
          )}

          <div className="login-divider">
            <span>HOẶC</span>
          </div>

          <BrutalButton
            className="brutal-btn--full google-login-btn"
            onClick={handleGoogleLogin}
            disabled={loading}
          >
            <svg
              width="18"
              height="18"
              viewBox="0 0 24 24"
              fill="currentColor"
              style={{ marginRight: 8 }}
            >
              <path d="M12.24 10.285V13.4h6.887C18.2 15.614 15.645 18 12.24 18c-3.86 0-7-3.14-7-7s3.14-7 7-7c1.706 0 3.267.614 4.5 1.636l2.455-2.455C17.378 1.583 14.99.9 12.24.9 6.27.9 1.4 5.77 1.4 11.75s4.87 10.85 10.84 10.85c6.23 0 10.36-4.38 10.36-10.55 0-.71-.06-1.25-.18-1.765H12.24z" />
            </svg>
            ĐĂNG NHẬP BẰNG GOOGLE
          </BrutalButton>

          <div className="login-register-prompt">
            Chưa có tài khoản?{" "}
            <Link to="/khachhang/dang-ky" className="register-link">
              Đăng ký ngay
            </Link>
          </div>
        </BrutalCard>
      </div>
    </div>
  );
}
