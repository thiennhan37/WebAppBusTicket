import React, { useState, useEffect } from "react";
import { useParams, useNavigate, Link } from "react-router-dom";
import { getOrderDetail, createPayment, createVNPayPayment, rateTrip, getTripRating } from "../../services/orderService";
import BrutalCard from "../../components/BrutalCard";
import BrutalButton from "../../components/BrutalButton";
import BrutalInput from "../../components/BrutalInput";
import { ArrowLeft, Calendar, Clock, MapPin, Star, AlertCircle, ShieldAlert, Award } from "lucide-react";
import { toast } from "sonner";
import "./OrderDetailPage.css";

export default function OrderDetailPage() {
  const { orderId } = useParams();
  const navigate = useNavigate();
  
  const [orderDetail, setOrderDetail] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // Rating states
  const [ratingDetail, setRatingDetail] = useState(null);
  const [showRatingForm, setShowRatingForm] = useState(false);
  const [serviceQuality, setServiceQuality] = useState(5);
  const [punctuality, setPunctuality] = useState(5);
  const [safety, setSafety] = useState(5);
  const [cleanliness, setCleanliness] = useState(5);
  const [description, setDescription] = useState("");
  const [ratingSubmitting, setRatingSubmitting] = useState(false);

  // Payment for unpaid booking in details
  const [paymentMethod, setPaymentMethod] = useState("vnpay");
  const [paying, setPaying] = useState(false);

  const fetchOrderDetail = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await getOrderDetail(orderId);
      const data = res.data.result || res.data;
      setOrderDetail(data);
      
      // If paid, fetch existing rating
      const isPaid = checkPaid(data.orderStatus);
      if (isPaid) {
        try {
          const rateRes = await getTripRating(orderId);
          if (rateRes.data.result) {
            setRatingDetail(rateRes.data.result);
          } else {
            setShowRatingForm(true);
          }
        } catch {
          // If 404 or error, it means rating doesn't exist yet
          setShowRatingForm(true);
        }
      }
    } catch (err) {
      console.error("Fetch order detail error:", err);
      setError("Không thể tải thông tin chi tiết đơn hàng này.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrderDetail();
  }, [orderId]);

  const checkPaid = (status) => {
    const s = (status || "").toUpperCase();
    return s === "PAID" || s === "SUCCESS" || s === "SUCCESSFUL" || s === "COMPLETED";
  };

  const getStatusBadge = (status) => {
    const s = (status || "").toUpperCase();
    if (checkPaid(s)) {
      return <span className="brutal-tag brutal-tag--green">ĐÃ THANH TOÁN</span>;
    }
    if (s === "PENDING" || s === "HOLDING") {
      return <span className="brutal-tag">CHỜ THANH TOÁN</span>;
    }
    return <span className="brutal-tag brutal-tag--red">ĐÃ HỦY</span>;
  };

  const handlePayment = async () => {
    if (!orderDetail) return;
    setPaying(true);
    try {
      // First update payment info (updates customer info with existing contact details)
      const payRes = await createPayment(orderId, {
        customerName: orderDetail.contactName,
        customerPhone: orderDetail.contactPhone,
        customerEmail: orderDetail.contactEmail,
      });

      if (paymentMethod === "momo") {
        const payUrl = payRes.data.result?.payUrl || payRes.data.payUrl;
        if (payUrl) {
          window.location.href = payUrl;
        } else {
          throw new Error("Không lấy được đường dẫn thanh toán Momo");
        }
      } else if (paymentMethod === "vnpay") {
        const vnpayRes = await createVNPayPayment(orderId);
        const payUrl = vnpayRes.data.result?.payUrl || vnpayRes.data.payUrl;
        if (payUrl) {
          window.location.href = payUrl;
        } else {
          throw new Error("Không lấy được đường dẫn thanh toán VNPAY");
        }
      }
    } catch (err) {
      console.error("Payment error:", err);
      toast.error("Thanh toán thất bại. Vui lòng thử lại!");
    } finally {
      setPaying(false);
    }
  };

  const handleRatingSubmit = async (e) => {
    e.preventDefault();
    setRatingSubmitting(true);
    try {
      await rateTrip(orderId, {
        serviceQuality,
        punctuality,
        safety,
        cleanliness,
        description,
      });
      toast.success("Cảm ơn bạn đã đánh giá chuyến đi!");
      // Reload order details to show review
      fetchOrderDetail();
    } catch (err) {
      console.error("Submit rating error:", err);
      toast.error("Gửi đánh giá thất bại. Vui lòng thử lại!");
    } finally {
      setRatingSubmitting(false);
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

  const renderStarSelector = (value, setter, label) => {
    return (
      <div className="star-selector-row">
        <span className="star-selector-label">{label}:</span>
        <div className="star-selector-stars">
          {[1, 2, 3, 4, 5].map((star) => (
            <Star
              key={star}
              size={24}
              className={`star-icon ${star <= value ? "star-icon--active" : ""}`}
              fill={star <= value ? "var(--color-yellow)" : "none"}
              onClick={() => setter(star)}
              style={{ cursor: "pointer" }}
            />
          ))}
        </div>
      </div>
    );
  };

  return (
    <div className="order-detail-page">
      <div className="container">
        <button className="brutal-btn" onClick={() => navigate("/khachhang/don-hang")} style={{ marginBottom: "1.5rem" }}>
          <ArrowLeft size={16} /> Danh sách đơn hàng
        </button>

        {loading ? (
          <div className="page-loader">
            <div className="brutal-spinner"></div>
            <p>Đang tải chi tiết đơn hàng...</p>
          </div>
        ) : error ? (
          <BrutalCard className="error-card text-center">
            <AlertCircle size={48} color="var(--color-red)" style={{ marginBottom: "1rem" }} />
            <h3>Đã xảy ra lỗi</h3>
            <p>{error}</p>
            <Link to="/khachhang/don-hang" className="brutal-btn brutal-btn--primary" style={{ marginTop: "1rem", display: "inline-block" }}>
              Về danh sách
            </Link>
          </BrutalCard>
        ) : (
          <div className="order-detail-layout">
            {/* Left Column: Ticket details */}
            <div className="order-main-info">
              <BrutalCard className="detail-card" noHover>
                <div className="detail-card-header">
                  <div>
                    <h3 className="detail-card-title text-mono">Chi tiết đơn hàng #{orderDetail?.bookingOrderId}</h3>
                    <div className="detail-company text-mono">{orderDetail?.busCompanyName} ({orderDetail?.busType})</div>
                  </div>
                  {getStatusBadge(orderDetail?.orderStatus)}
                </div>

                <div className="detail-route">
                  <div className="route-stop">
                    <MapPin size={18} />
                    <div>
                      <strong>{orderDetail?.pickupProvince}</strong>
                      <span>{orderDetail?.pickupStop}</span>
                    </div>
                  </div>
                  <div className="route-connector-line"></div>
                  <div className="route-stop">
                    <MapPin size={18} />
                    <div>
                      <strong>{orderDetail?.dropoffProvince}</strong>
                      <span>{orderDetail?.dropoffStop}</span>
                    </div>
                  </div>
                </div>

                <div className="detail-divider"></div>

                <div className="detail-time-grid">
                  <div className="time-grid-item">
                    <Calendar size={18} />
                    <div>
                      <div className="grid-label">Ngày khởi hành</div>
                      <div className="grid-val text-mono">{formatDate(orderDetail?.departureTime)}</div>
                    </div>
                  </div>

                  <div className="time-grid-item">
                    <Clock size={18} />
                    <div>
                      <div className="grid-label">Giờ khởi hành</div>
                      <div className="grid-val text-mono">{formatTime(orderDetail?.departureTime)}</div>
                    </div>
                  </div>
                </div>

                <div className="detail-divider"></div>

                <div className="detail-seats-info">
                  <span className="grid-label">Ghế đã đặt ({orderDetail?.seatCount} ghế):</span>
                  <div className="detail-seats-list" style={{ marginTop: "0.5rem" }}>
                    {orderDetail?.seatCodes?.map((code) => (
                      <span key={code} className="brutal-tag text-mono">
                        Ghế {code}
                      </span>
                    ))}
                  </div>
                </div>

                <div className="detail-divider"></div>

                <div className="detail-passenger">
                  <h4 className="detail-subtitle">Thông tin hành khách</h4>
                  <div className="passenger-row">
                    <span>Họ tên:</span>
                    <strong>{orderDetail?.contactName}</strong>
                  </div>
                  <div className="passenger-row">
                    <span>Số điện thoại:</span>
                    <strong className="text-mono">{orderDetail?.contactPhone}</strong>
                  </div>
                  <div className="passenger-row">
                    <span>Email liên hệ:</span>
                    <strong className="text-mono">{orderDetail?.contactEmail}</strong>
                  </div>
                </div>

                <div className="detail-divider"></div>

                <div className="detail-total">
                  <span>Tổng tiền thanh toán:</span>
                  <span className="total-price text-mono">
                    {new Intl.NumberFormat("vi-VN").format(orderDetail?.totalAmount || 0)}đ
                  </span>
                </div>
              </BrutalCard>
            </div>

            {/* Right Column: Payment or Review */}
            <div className="order-sidebar-action">
              {/* If unpaid (Pending / Holding), show payment widget */}
              {((orderDetail?.orderStatus || "").toUpperCase() === "PENDING" ||
                (orderDetail?.orderStatus || "").toUpperCase() === "HOLDING") && (
                <BrutalCard className="payment-widget-card" noHover>
                  <h3 className="widget-title">Hoàn tất thanh toán</h3>
                  <p className="widget-desc">Đơn hàng của bạn đang chờ thanh toán. Hãy chọn phương thức bên dưới.</p>

                  <div className="payment-options-widget">
                    <label className={`payment-option-row ${paymentMethod === "vnpay" ? "payment-option-row--selected" : ""}`}>
                      <input
                        type="radio"
                        name="paymentMethodWidget"
                        value="vnpay"
                        checked={paymentMethod === "vnpay"}
                        onChange={() => setPaymentMethod("vnpay")}
                      />
                      <strong>Thanh toán qua VNPAY</strong>
                    </label>

                    <label className={`payment-option-row ${paymentMethod === "momo" ? "payment-option-row--selected" : ""}`}>
                      <input
                        type="radio"
                        name="paymentMethodWidget"
                        value="momo"
                        checked={paymentMethod === "momo"}
                        onChange={() => setPaymentMethod("momo")}
                      />
                      <strong>Thanh toán qua Momo</strong>
                    </label>
                  </div>

                  <BrutalButton
                    variant="primary"
                    className="brutal-btn--full"
                    onClick={handlePayment}
                    disabled={paying}
                    style={{ marginTop: "1.5rem" }}
                  >
                    {paying ? "ĐANG LIÊN KẾT CỔNG..." : "THANH TOÁN NGAY"}
                  </BrutalButton>
                </BrutalCard>
              )}

              {/* If PAID, show Rating/Review widget */}
              {checkPaid(orderDetail?.orderStatus) && (
                <BrutalCard className="rating-widget-card" noHover>
                  <h3 className="widget-title">
                    <Award size={18} /> Đánh giá chuyến đi
                  </h3>

                  {showRatingForm && (
                    <form onSubmit={handleRatingSubmit} className="rating-form">
                      {renderStarSelector(serviceQuality, setServiceQuality, "Chất lượng dịch vụ")}
                      {renderStarSelector(punctuality, setPunctuality, "Đúng giờ")}
                      {renderStarSelector(safety, setSafety, "An toàn")}
                      {renderStarSelector(cleanliness, setCleanliness, "Vệ sinh")}

                      <div style={{ marginTop: "1rem" }}>
                        <label className="brutal-label">Ý kiến đóng góp</label>
                        <textarea
                          className="brutal-input rating-textarea"
                          rows="3"
                          placeholder="Chia sẻ trải nghiệm của bạn về chuyến xe này..."
                          value={description}
                          onChange={(e) => setDescription(e.target.value)}
                        ></textarea>
                      </div>

                      <BrutalButton
                        type="submit"
                        variant="primary"
                        className="brutal-btn--full"
                        disabled={ratingSubmitting}
                        style={{ marginTop: "1rem" }}
                      >
                        {ratingSubmitting ? "ĐANG GỬI..." : "GỬI ĐÁNH GIÁ"}
                      </BrutalButton>
                    </form>
                  )}

                  {ratingDetail && (
                    <div className="rating-result">
                      <div className="average-rating-indicator">
                        <Star size={20} fill="var(--color-yellow)" className="star-icon--active" />
                        <span className="avg-val">{ratingDetail.averageStars?.toFixed(1) || "5.0"}</span>
                        <span>/ 5.0</span>
                      </div>

                      <div className="rating-breakdown">
                        <div className="breakdown-item">
                          <span>Dịch vụ:</span>
                          <strong>{ratingDetail.serviceQuality} ★</strong>
                        </div>
                        <div className="breakdown-item">
                          <span>Đúng giờ:</span>
                          <strong>{ratingDetail.punctuality} ★</strong>
                        </div>
                        <div className="breakdown-item">
                          <span>An toàn:</span>
                          <strong>{ratingDetail.safety} ★</strong>
                        </div>
                        <div className="breakdown-item">
                          <span>Vệ sinh:</span>
                          <strong>{ratingDetail.cleanliness} ★</strong>
                        </div>
                      </div>

                      {ratingDetail.description && (
                        <div className="rating-comment brutal-card" style={{ marginTop: "1rem", backgroundColor: "var(--color-gray-100)" }}>
                          <span className="brutal-label" style={{ marginBottom: 4 }}>Nhận xét của bạn</span>
                          <p style={{ fontSize: "var(--font-size-sm)", fontStyle: "italic" }}>"{ratingDetail.description}"</p>
                        </div>
                      )}
                    </div>
                  )}
                </BrutalCard>
              )}

              {/* If Cancelled, show notice */}
              {(orderDetail?.orderStatus || "").toUpperCase() === "CANCELLED" && (
                <BrutalCard className="cancelled-widget-card" noHover>
                  <ShieldAlert size={36} color="var(--color-red)" style={{ marginBottom: "0.5rem" }} />
                  <h3 className="widget-title">Đơn hàng đã hủy</h3>
                  <p className="widget-desc" style={{ fontSize: "var(--font-size-xs)" }}>
                    Đơn hàng đã được giải phóng ghế do hết thời gian giữ chỗ hoặc do bạn chủ động hủy. Vui lòng đặt chuyến khác!
                  </p>
                  <Link to="/khachhang" className="brutal-btn brutal-btn--primary brutal-btn--full" style={{ marginTop: "1rem", textAlign: "center", display: "block" }}>
                    TÌM CHUYẾN MỚI
                  </Link>
                </BrutalCard>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
