import {useEffect, useMemo, useState} from "react";
import {useLocation, useNavigate, useParams, useSearchParams} from "react-router-dom";
import {createPayment, createVNPayPayment, unholdSeats} from "../../services/orderService";
import BrutalCard from "../../components/BrutalCard";
import BrutalButton from "../../components/BrutalButton";
import {ArrowLeft, Clock, MapPin} from "lucide-react";
import {toast} from "sonner";
import "../Booking/BookingPage.css";
import "./PaymentPage.css";

const HOLD_DURATION_SECONDS = 10 * 60;

export default function PaymentPage() {
    const {tripId} = useParams();
    const [searchParams] = useSearchParams();
    const navigate = useNavigate();
    const location = useLocation();
    const state = location.state || {};

    const orderId = state.orderId || searchParams.get("orderId");
    const [holdStartedAt] = useState(() => state.holdStartedAt || Date.now());
    const [paymentMethod, setPaymentMethod] = useState("vnpay");
    const [submitting, setSubmitting] = useState(false);
    const [remainingSeconds, setRemainingSeconds] = useState(() => {
        const elapsedSeconds = Math.floor((Date.now() - holdStartedAt) / 1000);
        return Math.max(HOLD_DURATION_SECONDS - elapsedSeconds, 0);
    });

    const hasRequiredState = Boolean(
        orderId &&
        state.customerName &&
        state.customerPhone &&
        state.customerEmail &&
        state.selectedPickupStopId &&
        state.selectedDropoffStopId
    );

    useEffect(() => {
        if (!hasRequiredState) {
            toast.error("Thiếu thông tin thanh toán. Vui lòng thực hiện lại từ bước chọn ghế.");
            navigate(`/khachhang/chon-ghe/${tripId}`, {replace: true});
            return;
        }

        const timer = window.setInterval(() => {
            const elapsedSeconds = Math.floor((Date.now() - holdStartedAt) / 1000);
            setRemainingSeconds(Math.max(HOLD_DURATION_SECONDS - elapsedSeconds, 0));
        }, 1000);

        return () => window.clearInterval(timer);
    }, [hasRequiredState, holdStartedAt, navigate, tripId]);

    useEffect(() => {
        if (!hasRequiredState || remainingSeconds > 0) return;

        const releaseSeats = async () => {
            try {
                await unholdSeats(orderId);
            } catch (err) {
                console.error("Auto unhold seats error:", err);
            } finally {
                toast.error("Phiên giữ chỗ đã hết hạn. Vui lòng chọn lại ghế.");
                navigate(`/khachhang/chon-ghe/${tripId}`, {replace: true});
            }
        };

        releaseSeats();
    }, [hasRequiredState, navigate, orderId, remainingSeconds, tripId]);

    const formattedCountdown = useMemo(() => {
        const minutes = Math.floor(remainingSeconds / 60).toString().padStart(2, "0");
        const seconds = (remainingSeconds % 60).toString().padStart(2, "0");
        return `${minutes}:${seconds}`;
    }, [remainingSeconds]);

    const handleCancelBooking = async () => {
        try {
            await unholdSeats(orderId);
            toast.success("Đã hủy giữ ghế thành công.");
            navigate("/khachhang");
        } catch (err) {
            console.error("Unhold seats error:", err);
            toast.error("Hủy giữ ghế thất bại. Đơn hàng có thể đã quá hạn tự hủy.");
            navigate("/khachhang");
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (remainingSeconds <= 0) {
            toast.error("Phiên giữ chỗ đã hết hạn. Vui lòng chọn lại ghế.");
            return;
        }

        setSubmitting(true);
        try {
            if (paymentMethod === "vnpay") {
                const vnpayRes = await createVNPayPayment(orderId);
                const payUrl = vnpayRes.data.result?.payUrl || vnpayRes.data.payUrl;
                if (!payUrl) throw new Error("KhÃ´ng láº¥y Ä‘Æ°á»£c Ä‘Æ°á»ng dáº«n thanh toÃ¡n VNPAY");
                toast.success("Äang chuyá»ƒn hÆ°á»›ng sang VNPAY...");
                window.location.href = payUrl;
                return;
            }

            const payRes = await createPayment(orderId, {
                customerName: state.customerName,
                customerPhone: state.customerPhone,
                customerEmail: state.customerEmail,
                pickupStopId: state.selectedPickupStopId,
                dropoffStopId: state.selectedDropoffStopId,
            });

            if (paymentMethod === "momo") {
                const payUrl = payRes.data.result?.payUrl || payRes.data.payUrl;
                if (!payUrl) throw new Error("Không lấy được đường dẫn thanh toán Momo");
                toast.success("Đang chuyển hướng sang Momo...");
                window.location.href = payUrl;
                return;
            }

            const vnpayRes = await createVNPayPayment(orderId);
            const payUrl = vnpayRes.data.result?.payUrl || vnpayRes.data.payUrl;
            if (!payUrl) throw new Error("Không lấy được đường dẫn thanh toán VNPAY");
            toast.success("Đang chuyển hướng sang VNPAY...");
            window.location.href = payUrl;
        } catch (err) {
            console.error("Payment registration error:", err);
            const errMsg = err.response?.data?.message || err.message || "Không thể tiến hành thanh toán. Vui lòng thử lại!";
            toast.error(errMsg);
        } finally {
            setSubmitting(false);
        }
    };

    return (
        <div className="booking-page">
            <div className="container">
                <div className="booking-actions">
                    <button className="brutal-btn" onClick={() => navigate(-1)}>
                        <ArrowLeft size={16}/> Quay lại
                    </button>
                    <button className="brutal-btn brutal-btn--danger" onClick={handleCancelBooking}>
                        Hủy giữ ghế
                    </button>
                </div>

                <div className="booking-layout">
                    <form className="booking-form-section" onSubmit={handleSubmit}>
                        <BrutalCard className="payment-card" noHover>
                            <div className="hold-countdown">
                                <Clock size={22}/>
                                <div>
                                    <span>Thời gian giữ chỗ còn lại</span>
                                    <strong className="text-mono">{formattedCountdown}</strong>
                                </div>
                            </div>

                            <h3 className="form-card__title">Phương thức thanh toán</h3>

                            <div className="payment-options">
                                <label
                                    className={`payment-option-label brutal-card ${paymentMethod === "vnpay" ? "payment-option-label--selected" : ""}`}
                                >
                                    <input
                                        type="radio"
                                        name="paymentMethod"
                                        value="vnpay"
                                        checked={paymentMethod === "vnpay"}
                                        onChange={() => setPaymentMethod("vnpay")}
                                    />
                                    <div className="payment-option-info">
                                        <strong>Cổng thanh toán VNPAY</strong>
                                        <span>Thanh toán qua tài khoản ngân hàng, ATM, hoặc mã QR ngân hàng.</span>
                                    </div>
                                </label>

                                <label
                                    className={`payment-option-label brutal-card ${paymentMethod === "momo" ? "payment-option-label--selected" : ""}`}
                                >
                                    <input
                                        type="radio"
                                        name="paymentMethod"
                                        value="momo"
                                        checked={paymentMethod === "momo"}
                                        onChange={() => setPaymentMethod("momo")}
                                    />
                                    <div className="payment-option-info">
                                        <strong>Ví Momo</strong>
                                        <span>Thanh toán nhanh qua ví điện tử Momo trên điện thoại di động.</span>
                                    </div>
                                </label>
                            </div>

                            <div className="booking-submit-wrapper">
                                <BrutalButton
                                    type="submit"
                                    variant="primary"
                                    size="large"
                                    className="brutal-btn--full"
                                    disabled={submitting || remainingSeconds <= 0}
                                >
                                    {submitting ? "ĐANG TẠO THANH TOÁN..." : "THANH TOÁN NGAY"}
                                </BrutalButton>
                            </div>
                        </BrutalCard>
                    </form>

                    <div className="booking-summary-section">
                        <BrutalCard className="ticket-summary-card" noHover>
                            <h3 className="ticket-summary-title">Tóm tắt chuyến đi</h3>

                            <div className="ticket-summary-route">
                                <div className="station-indicator">
                                    <MapPin size={16}/>
                                    <div>
                                        <strong>Điểm đón</strong>
                                        <span className="station-detail">
                                            {state.selectedPickupStop?.stop?.name || state.selectedPickupStopId}
                                        </span>
                                        <span className="station-detail">
                                            {state.selectedPickupStop?.stop?.address}
                                        </span>
                                    </div>
                                </div>
                                <div className="route-connector"></div>
                                <div className="station-indicator">
                                    <MapPin size={16}/>
                                    <div>
                                        <strong>Điểm trả</strong>
                                        <span className="station-detail">
                                            {state.selectedDropoffStop?.stop?.name || state.selectedDropoffStopId}
                                        </span>
                                        <span className="station-detail">
                                            {state.selectedDropoffStop?.stop?.address}
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div className="ticket-summary-divider"></div>

                            <div className="ticket-summary-seats">
                                <div className="detail-item__label">Danh sách ghế ({state.selectedSeatIds?.length || 0} ghế)</div>
                                <div className="seats-tags" style={{marginTop: "0.5rem"}}>
                                    {(state.selectedSeatCodes || []).map((code) => (
                                        <span key={code} className="brutal-tag text-mono">Ghế {code}</span>
                                    ))}
                                </div>
                            </div>

                            <div className="ticket-summary-divider"></div>

                            <div className="ticket-summary-total">
                                <span>Tổng tiền thanh toán:</span>
                                <span className="total-value text-mono">
                                    {new Intl.NumberFormat("vi-VN").format(state.totalCost || 0)}đ
                                </span>
                            </div>
                        </BrutalCard>
                    </div>
                </div>
            </div>
        </div>
    );
}
