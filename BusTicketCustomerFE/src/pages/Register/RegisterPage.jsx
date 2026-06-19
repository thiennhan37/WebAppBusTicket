import React, {useState, useEffect} from "react";
import {useNavigate, Link, useSearchParams} from "react-router-dom";
import {useAuth} from "../../context/AuthContext";
import {initiateRegistration, verifyRegistration} from "../../services/authService";
import BrutalCard from "../../components/BrutalCard";
import BrutalButton from "../../components/BrutalButton";
import BrutalInput from "../../components/BrutalInput";
import BrutalSelect from "../../components/BrutalSelect";
import {toast} from "sonner";
import "./RegisterPage.css";

export default function RegisterPage() {
    const [searchParams] = useSearchParams();
    const navigate = useNavigate();
    const {login} = useAuth();

    const [fullName, setFullName] = useState("");
    const [email, setEmail] = useState("");
    const [phone, setPhone] = useState("");
    const [gender, setGender] = useState("Nam");
    const [dob, setDob] = useState(""); // input type="date" gives yyyy-mm-dd
    const [idRegion, setIdRegion] = useState("+84");
    const [otp, setOtp] = useState("");

    const [step, setStep] = useState(1); // 1: Info Form, 2: OTP verify
    const [loading, setLoading] = useState(false);
    const [resendOtpTimer, setResendOtpTimer] = useState(0);

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

    // === Đăng ký thường (OTP) ===
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
            setResendOtpTimer(30);
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
            setResendOtpTimer(30);
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
            const {customerInfo, accessToken, refreshToken} = res.data.result || res.data;

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

    const countries = [
        {value: "+84", label: "🇻🇳 +84 (VN)"},
        {value: "+1", label: "🇺🇸 +1 (US)"},
        {value: "+44", label: "🇬🇧 +44 (UK)"},
        {value: "+81", label: "🇯🇵 +81 (JP)"},
        {value: "+82", label: "🇰🇷 +82 (KR)"},
        {value: "+66", label: "🇹🇭 +66 (TH)"},
        {value: "+65", label: "🇸🇬 +65 (SG)"},
    ];

    return (
        <div className="register-page">
            <div className="container">
                <BrutalCard className="register-card" noHover>
                    <div className="register-card__header">
                        <h2 className="register-card__title">Đăng ký tài khoản</h2>
                        <p className="register-card__subtitle">Tạo tài khoản khách hàng mới trong vài giây</p>
                    </div>

                    {step === 1 ? (
                        <form onSubmit={handleRegisterInit}>
                            <BrutalInput
                                label="Họ và tên"
                                id="register-fullname"
                                placeholder="Nguyễn Văn A"
                                value={fullName}
                                onChange={(e) => setFullName(e.target.value)}
                                required
                            />

                            <BrutalInput
                                label="Email"
                                id="register-email"
                                type="email"
                                placeholder="nguyenvana@gmail.com"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                required
                            />

                            <div className="phone-row">
                                <div style={{width: "130px"}}>
                                    <BrutalSelect
                                        label="Mã vùng"
                                        id="register-region"
                                        options={countries}
                                        value={idRegion}
                                        onChange={(e) => setIdRegion(e.target.value)}
                                    />
                                </div>
                                <div style={{flex: 1}}>
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
                                <div style={{flex: 1}}>
                                    <BrutalInput
                                        label="Ngày sinh"
                                        id="register-dob"
                                        type="date"
                                        value={dob}
                                        onChange={(e) => setDob(e.target.value)}
                                        required
                                    />
                                </div>
                                <div style={{width: "130px"}}>
                                    <BrutalSelect
                                        label="Giới tính"
                                        id="register-gender"
                                        options={[
                                            {value: "Nam", label: "Nam"},
                                            {value: "Nữ", label: "Nữ"},
                                            {value: "Khác", label: "Khác"},
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
                        </form>
                    ) : (
                        <form onSubmit={handleRegisterVerify}>
                            <div className="otp-intro-alert text-mono">
                                Mã xác thực đăng ký đã gửi tới email: <br/>
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