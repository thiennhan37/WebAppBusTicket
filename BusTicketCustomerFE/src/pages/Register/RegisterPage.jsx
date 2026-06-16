import React, { useState, useEffect, useRef } from "react";
import { useNavigate, Link, useSearchParams } from "react-router-dom";
import { useAuth } from "../../context/AuthContext";
import { initiateRegistration, verifyRegistration, getGoogleLoginUrl, googleCallback } from "../../services/authService";
import BrutalCard from "../../components/BrutalCard";
import BrutalButton from "../../components/BrutalButton";
import BrutalInput from "../../components/BrutalInput";
import BrutalSelect from "../../components/BrutalSelect";
import { UserPlus, ArrowLeft } from "lucide-react";
import { toast } from "sonner";
import "./RegisterPage.css";

export default function RegisterPage() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const { login } = useAuth();
  const oauthCode = searchParams.get("code");
  const callbackCalled = useRef(false);

  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [gender, setGender] = useState("Nam");
  const [dob, setDob] = useState(""); // input type="date" gives yyyy-mm-dd
  const [idRegion, setIdRegion] = useState("+84");
  const [otp, setOtp] = useState("");
  
  const [step, setStep] = useState(1); // 1: Info Form, 2: OTP verify
  const [loading, setLoading] = useState(false);
  const [isGoogleRegister, setIsGoogleRegister] = useState(false);
  const [resendOtpTimer, setResendOtpTimer] = useState(0); // New state for OTP resend timer

  // Xử lý khi nhận được callback từ Google
  useEffect(() => {
    if (oauthCode && !callbackCalled.current) {
      callbackCalled.current = true;
      const fetchGoogleInfo = async () => {
        setLoading(true);
        try {
          // Tận dụng callback để lấy thông tin user
          const res = await googleCallback(oauthCode);
          // Nếu backend trả về kết quả thành công, lấy thông tin profile
          const result = res.data.result || res.data;
          
          // Thông tin thường nằm trong customerInfo hoặc chính object result tùy theo cấu trúc API
          const profile = result.customerInfo || result;

          if (profile) {
            setFullName(profile.fullName || "");
            setEmail(profile.email || "");
            setIsGoogleRegister(true);
            toast.success("Xác thực Google thành công! Vui lòng bổ sung các thông tin còn lại.");
          }
        } catch (err) {
          console.error("Lỗi lấy thông tin Google:", err);
          toast.error("Không thể kết nối với tài khoản Google.");
        } finally {
          setLoading(false);
        }
      };
      fetchGoogleInfo();
    }
  }, [oauthCode]);

  // OTP Resend Timer Effect
  useEffect(() => {
    let timer;
    if (resendOtpTimer > 0) {
      timer = setInterval(() => {
        setResendOtpTimer((prev) => prev - 1);
      }, 1000);
    }
    return () => clearInterval(timer);
  }, [resendOtpTimer]);

  // Format date from yyyy-mm-dd to dd/mm/yyyy for backend JsonFormat
  const formatDateForBackend = (dateString) => {
    if (!dateString) return "";
    const [yyyy, mm, dd] = dateString.split("-");
    return `${dd}/${mm}/${yyyy}`;
  };

  const handleRegisterInit = async (e) => {
    e.preventDefault();
    if (!fullName || !email || !phone || !dob || !idRegion || !gender) {
      toast.error("Vui lòng nhập đầy đủ thông tin");
      return;
    }

    setLoading(true);
    try {
      await initiateRegistration({
        fullName,
        email,
        phone,
        idRegion,
        gender,
        dob: formatDateForBackend(dob),
      });
      toast.success("Mã OTP đã được gửi đến email đăng ký.");
      setStep(2);
      setResendOtpTimer(30); // Start 30-second timer
    } catch (err) {
      console.error("Register init error:", err);
      const errMsg = err.response?.data?.message || "Đăng ký thất bại. Email hoặc Số điện thoại có thể đã tồn tại!";
      toast.error(errMsg);
    } finally {
      setLoading(false);
    }
  };

  const handleResendOtp = async () => {
    if (!email || resendOtpTimer > 0) return;

    setLoading(true);
    try {
      await initiateRegistration({
        fullName,
        email,
        phone,
        idRegion,
        gender,
        dob: formatDateForBackend(dob),
      });
      toast.success("Mã OTP mới đã được gửi đến email của bạn.");
      setResendOtpTimer(30); // Reset and start 30-second timer
    } catch (err) {
      console.error("Resend OTP error:", err);
      const msg = err.response?.data?.message || "Không thể gửi lại OTP. Vui lòng thử lại!";
      toast.error(msg);
    } finally {
      setLoading(false);
    }
  };

  const handleRegisterVerify = async (e) => {
    e.preventDefault();
    if (!otp) return;

    setLoading(true);
    try {
      const res = await verifyRegistration(email, otp);
      const { customerInfo, accessToken, refreshToken } = res.data.result || res.data;
      
      login(customerInfo, accessToken, refreshToken);
      toast.success("Đăng ký tài khoản thành công!");
      navigate("/khachhang");
    } catch (err) {
      console.error("Register verify error:", err);
      toast.error("Mã xác thực OTP không đúng hoặc đã quá hạn!");
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleLoginClick = async () => {
    try {
      const res = await getGoogleLoginUrl();
      const googleUrl = res.data.result || res.data;
      if (googleUrl) {
        // Chuyển hướng sang Google, sau khi xong Google sẽ redirect về lại trang này với ?code=...
        window.location.href = googleUrl;
      } else {
        throw new Error("Không lấy được link đăng nhập Google");
      }
    } catch (err) {
      console.error("Google URL error:", err);
      toast.error("Lỗi khởi tạo đăng ký bằng Google!");
    }
  };

  // Hủy chế độ Google nếu người dùng muốn nhập thủ công lại từ đầu
  const handleResetGoogleMode = () => {
    setIsGoogleRegister(false);
    setFullName("");
    setEmail("");
    // Xóa code trên URL để tránh trigger lại useEffect
    navigate("/khachhang/dang-ky", { replace: true });
    callbackCalled.current = false;
  };

  const countries = [
    { value: "+84", label: "🇻🇳 +84 (VN)" },
    { value: "+1", label: "🇺🇸 +1 (US)" },
    { value: "+44", label: "🇬🇧 +44 (UK)" },
    { value: "+81", label: "🇯🇵 +81 (JP)" },
    { value: "+82", label: "🇰🇷 +82 (KR)" },
    { value: "+66", label: "🇹🇭 +66 (TH)" },
    { value: "+65", label: "🇸🇬 +65 (SG)" },
  ];

  return (
    <div className="register-page">
      <div className="container">
        <BrutalCard className="register-card" noHover>
          <div className="register-card__header">
            <h2 className="register-card__title">Đăng ký tài khoản</h2>
            <p className="register-card__subtitle">Tạo tài khoản khách hàng mới trong vài giây</p>
          </div>

          {isGoogleRegister && step === 1 && (
            <div className="google-info-alert" style={{ marginBottom: '20px', padding: '10px', backgroundColor: '#e7f3ff', border: '1px solid #1877f2', borderRadius: '8px', fontSize: '13px' }}>
              <p style={{ margin: 0, color: '#1877f2', fontWeight: 'bold' }}>
                ✨ Đã liên kết với Google: <b>{email}</b>
              </p>
              <button onClick={handleResetGoogleMode} style={{ background: 'none', border: 'none', color: '#666', textDecoration: 'underline', cursor: 'pointer', padding: 0, marginTop: '5px' }}>Dùng email khác</button>
            </div>
          )}

          {step === 1 ? (
            <form onSubmit={handleRegisterInit}>
              <BrutalInput
                label="Họ và tên"
                id="register-fullname"
                placeholder="Nguyễn Văn A"
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                required
                disabled={isGoogleRegister} // Khóa để tránh sửa dữ liệu đã xác thực từ Google
              />

              <BrutalInput
                label="Email"
                id="register-email"
                type="email"
                placeholder="nguyenvana@gmail.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                disabled={isGoogleRegister} // Khóa email
              />

              <div className="phone-row">
                <div style={{ width: "130px" }}> {/* Changed from 100px to 130px */}
                  <BrutalSelect
                    label="Mã vùng"
                    id="register-region"
                    options={countries}
                    value={idRegion}
                    onChange={(e) => setIdRegion(e.target.value)}
                  />
                </div>
                <div style={{ flex: 1 }}>
                  <BrutalInput
                    label="Số điện thoại"
                    id="register-phone"
                    type="tel"
                    placeholder="0987654321"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    required
                  />
                </div>
              </div>

              <div className="phone-row">
                <div style={{ flex: 1 }}>
                  <BrutalInput
                    label="Ngày sinh"
                    id="register-dob"
                    type="date"
                    value={dob}
                    onChange={(e) => setDob(e.target.value)}
                    required
                  />
                </div>
                <div style={{ width: "130px" }}>
                  <BrutalSelect
                    label="Giới tính"
                    id="register-gender"
                    options={[
                      { value: "Nam", label: "Nam" },
                      { value: "Nữ", label: "Nữ" },
                      { value: "Khác", label: "Khác" },
                    ]}
                    value={gender}
                    onChange={(e) => setGender(e.target.value)}
                    required
                  />
                </div>
              </div>

              <BrutalButton
                type="submit"
                variant="primary"
                size="large"
                className="brutal-btn--full"
                disabled={loading}
              >
                {loading ? "ĐANG KHỞI TẠO..." : "ĐĂNG KÝ & GỬI OTP"}
              </BrutalButton>

              {!isGoogleRegister && (
                <>
                  <div className="login-divider" style={{ margin: '20px 0', textAlign: 'center', position: 'relative' }}>
                    <span style={{ background: '#fff', padding: '0 10px', fontSize: '12px', color: '#666' }}>HOẶC</span>
                    <div style={{ position: 'absolute', top: '50%', left: 0, right: 0, height: '1px', background: '#eee', zIndex: -1 }}></div>
                  </div>

                  <BrutalButton
                    type="button"
                    className="brutal-btn--full google-login-btn"
                    onClick={handleGoogleLoginClick}
                    disabled={loading}
                  >
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" style={{ marginRight: 8 }}>
                      <path d="M12.24 10.285V13.4h6.887C18.2 15.614 15.645 18 12.24 18c-3.86 0-7-3.14-7-7s3.14-7 7-7c1.706 0 3.267.614 4.5 1.636l2.455-2.455C17.378 1.583 14.99.9 12.24.9 6.27.9 1.4 5.77 1.4 11.75s4.87 10.85 10.84 10.85c6.23 0 10.36-4.38 10.36-10.55 0-.71-.06-1.25-.18-1.765H12.24z" />
                    </svg>
                    TIẾP TỤC VỚI GOOGLE
                  </BrutalButton>
                </>
              )}
            </form>
          ) : (
            <form onSubmit={handleRegisterVerify}>
              <div className="otp-intro-alert text-mono">
                Mã xác thực đăng ký đã gửi tới email: <br />
                <strong>{email}</strong>
              </div>

              <BrutalInput
                label="Mã xác thực OTP"
                id="register-otp"
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
                  Quay lại chỉnh sửa thông tin
                </button>
                <button
                  type="button"
                  className="resend-otp-btn text-mono"
                  onClick={handleResendOtp}
                  disabled={loading || resendOtpTimer > 0}
                >
                  {resendOtpTimer > 0 ? `Gửi lại OTP (${resendOtpTimer}s)` : "Gửi lại OTP"}
                </button>
              </div>

              <BrutalButton
                type="submit"
                variant="primary"
                size="large"
                className="brutal-btn--full"
                disabled={loading}
              >
                {loading ? "ĐANG XÁC THỰC..." : "HOÀN TẤT ĐĂNG KÝ"}
              </BrutalButton>
            </form>
          )}

          <div className="register-login-prompt">
            Đã có tài khoản?{" "}
            <Link to="/khachhang/dang-nhap" className="login-link">
              Đăng nhập ngay
            </Link>
          </div>
        </BrutalCard>
      </div>
    </div>
  );
}