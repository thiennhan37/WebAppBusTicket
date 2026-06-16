import React, { useState, useEffect } from "react";
import { useSearchParams, useNavigate, useParams } from "react-router-dom";
import { getOrderDetail, createPayment, createVNPayPayment, unholdSeats } from "../../services/orderService";
import { useAuth } from "../../context/AuthContext";
import BrutalCard from "../../components/BrutalCard";
import BrutalButton from "../../components/BrutalButton";
import BrutalInput from "../../components/BrutalInput";
import { CreditCard, Calendar, Clock, MapPin, AlertCircle, ArrowLeft } from "lucide-react";
import { toast } from "sonner";
import "./BookingPage.css";

export default function BookingPage() {
  const { tripId } = useParams();
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const { user } = useAuth();
  
  const orderId = searchParams.get("orderId");
  
  const [orderDetail, setOrderDetail] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // Form contact details
  const [customerName, setCustomerName] = useState("");
  const [customerPhone, setCustomerPhone] = useState("");
  const [customerEmail, setCustomerEmail] = useState("");
  const [paymentMethod, setPaymentMethod] = useState("vnpay"); // vnpay, momo
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (!orderId) {
      setError("Không tìm thấy thông tin đơn hàng!");
      setLoading(false);
      return;
    }

    const fetchOrder = async () => {
      setLoading(true);
      setError(null);
      try {
        const res = await getOrderDetail(orderId);
        const data = res.data.result || res.data;
        setOrderDetail(data);
        
        // Populate contact info from order or fallback to authenticated user
        setCustomerName(data.contactName || user?.fullName || "");
        setCustomerPhone(data.contactPhone || user?.phone || "");
        setCustomerEmail(data.contactEmail || user?.email || "");
      } catch (err) {
        console.error("Fetch order detail error:", err);
        setError("Không thể tải thông tin chi tiết đơn hàng hoặc phiên giữ ghế đã hết hạn!");
      } finally {
        setLoading(false);
      }
    };

    fetchOrder();
  }, [orderId, user]);

  const handleCancelBooking = async () => {
    if (!window.confirm("Bạn có chắc chắn muốn hủy đơn hàng này và giải phóng các ghế đã chọn?")) {
      return;
    }
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
    if (!customerName || !customerPhone || !customerEmail) {
      toast.error("Vui lòng điền đầy đủ thông tin liên hệ");
      return;
    }

    setSubmitting(true);
    try {
      // 1. Update order with customer info and initiate payment (Momo by default returns payUrl)
      const payRes = await createPayment(orderId, {
        customerName,
        customerPhone,
        customerEmail,
      });

      if (paymentMethod === "momo") {
        const payUrl = payRes.data.result?.payUrl || payRes.data.payUrl;
        if (payUrl) {
          toast.success("Đang chuyển hướng sang Momo...");
          window.location.href = payUrl;
        } else {
          throw new Error("Không lấy được đường dẫn thanh toán Momo");
        }
      } else if (paymentMethod === "vnpay") {
        // 2. Call VNPay payment URL generator
        const vnpayRes = await createVNPayPayment(orderId);
        const payUrl = vnpayRes.data.result?.payUrl || vnpayRes.data.payUrl;
        if (payUrl) {
          toast.success("Đang chuyển hướng sang VNPAY...");
          window.location.href = payUrl;
        } else {
          throw new Error("Không lấy được đường dẫn thanh toán VNPAY");
        }
      }
    } catch (err) {
      console.error("Payment registration error:", err);
      const errMsg = err.response?.data?.message || err.message || "Không thể tiến hành thanh toán. Vui lòng thử lại!";
      toast.error(errMsg);
    } finally {
      setSubmitting(false);
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return "";
    const date = new Date(dateString);
    return date.toLocaleDateString("vi-VN", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
    });
  };

  const formatTime = (dateString) => {
    if (!dateString) return "";
    const date = new Date(dateString);
    return date.toLocaleTimeString("vi-VN", {
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  return (
    <div className="booking-page">
      <div className="container">
        <div className="booking-actions">
          <button className="brutal-btn" onClick={() => navigate(-1)}>
            <ArrowLeft size={16} /> Quay lại
          </button>
          <button className="brutal-btn brutal-btn--danger" onClick={handleCancelBooking}>
            Hủy giữ ghế
          </button>
        </div>

        {loading ? (
          <div className="page-loader">
            <div className="brutal-spinner"></div>
            <p>Đang tải thông tin đơn hàng...</p>
          </div>
        ) : error ? (
          <BrutalCard className="error-card text-center">
            <AlertCircle size={48} color="var(--color-red)" style={{ marginBottom: "1rem" }} />
            <h3>Đã xảy ra lỗi</h3>
            <p>{error}</p>
            <BrutalButton variant="primary" onClick={() => navigate("/khachhang")} style={{ marginTop: "1rem" }}>
              Quay lại trang chủ
            </BrutalButton>
          </BrutalCard>
        ) : (
          <div className="booking-layout">
            {/* Left Column: Contact Form & Payment Method */}
            <div className="booking-form-section">
              <form onSubmit={handleSubmit}>
                <BrutalCard className="form-card" noHover>
                  <h3 className="form-card__title">Thông tin khách hàng</h3>
                  
                  <BrutalInput
                    label="Họ và tên"
                    id="customer-name"
                    placeholder="Nhập họ và tên người đi xe..."
                    value={customerName}
                    onChange={(e) => setCustomerName(e.target.value)}
                    required
                  />

                  <BrutalInput
                    label="Số điện thoại"
                    id="customer-phone"
                    type="tel"
                    placeholder="Nhập số điện thoại..."
                    value={customerPhone}
                    onChange={(e) => setCustomerPhone(e.target.value)}
                    required
                  />

                  <BrutalInput
                    label="Địa chỉ Email"
                    id="customer-email"
                    type="email"
                    placeholder="Nhập email nhận vé..."
                    value={customerEmail}
                    onChange={(e) => setCustomerEmail(e.target.value)}
                    required
                  />
                </BrutalCard>

                <BrutalCard className="payment-card" noHover style={{ marginTop: "2rem" }}>
                  <h3 className="form-card__title">Phương thức thanh toán</h3>

                  <div className="payment-options">
                    <label className={`payment-option-label brutal-card ${paymentMethod === "vnpay" ? "payment-option-label--selected" : ""}`}>
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

                    <label className={`payment-option-label brutal-card ${paymentMethod === "momo" ? "payment-option-label--selected" : ""}`}>
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
                </BrutalCard>

                <div className="booking-submit-wrapper">
                  <BrutalButton
                    type="submit"
                    variant="primary"
                    size="large"
                    className="brutal-btn--full"
                    disabled={submitting}
                  >
                    {submitting ? "ĐANG TIẾN HÀNH THANH TOÁN..." : "XÁC NHẬN THANH TOÁN & ĐẶT VÉ"}
                  </BrutalButton>
                </div>
              </form>
            </div>

            {/* Right Column: Order Ticket Summary */}
            <div className="booking-summary-section">
              <BrutalCard className="ticket-summary-card" noHover>
                <h3 className="ticket-summary-title">Tóm tắt chuyến đi</h3>
                
                <div className="ticket-summary-company text-mono">
                  {orderDetail?.busCompanyName}
                </div>
                
                <div className="ticket-summary-route">
                  <div className="station-indicator">
                    <MapPin size={16} />
                    <div>
                      <strong>{orderDetail?.pickupProvince}</strong>
                      <span className="station-detail">{orderDetail?.pickupStop}</span>
                    </div>
                  </div>
                  <div className="route-connector"></div>
                  <div className="station-indicator">
                    <MapPin size={16} />
                    <div>
                      <strong>{orderDetail?.dropoffProvince}</strong>
                      <span className="station-detail">{orderDetail?.dropoffStop}</span>
                    </div>
                  </div>
                </div>

                <div className="ticket-summary-divider"></div>

                <div className="ticket-summary-details">
                  <div className="detail-item">
                    <Calendar size={16} />
                    <div>
                      <div className="detail-item__label">Ngày khởi hành</div>
                      <div className="detail-item__val text-mono">{formatDate(orderDetail?.departureTime)}</div>
                    </div>
                  </div>

                  <div className="detail-item">
                    <Clock size={16} />
                    <div>
                      <div className="detail-item__label">Giờ khởi hành</div>
                      <div className="detail-item__val text-mono">{formatTime(orderDetail?.departureTime)}</div>
                    </div>
                  </div>
                </div>

                <div className="ticket-summary-divider"></div>

                <div className="ticket-summary-seats">
                  <div className="detail-item__label">Danh sách ghế ({orderDetail?.seatCount} ghế)</div>
                  <div className="seats-tags" style={{ marginTop: "0.5rem" }}>
                    {orderDetail?.seatCodes?.map((code) => (
                      <span key={code} className="brutal-tag text-mono">
                        Ghế {code}
                      </span>
                    ))}
                  </div>
                </div>

                <div className="ticket-summary-divider"></div>

                <div className="ticket-summary-total">
                  <span>Tổng tiền thanh toán:</span>
                  <span className="total-value text-mono">
                    {new Intl.NumberFormat("vi-VN").format(orderDetail?.totalAmount || 0)}đ
                  </span>
                </div>
              </BrutalCard>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
