import React, { useState, useEffect, useCallback } from "react";
import { Link } from "react-router-dom";
import { getRecentOrders, unholdSeats, rateTrip, getTripRating } from "../../services/orderService";
import { useAuth } from "../../context/AuthContext";
import BrutalCard from "../../components/BrutalCard";
import BrutalButton from "../../components/BrutalButton";
import { ClipboardList, ArrowRight, Calendar, Info, Clock, User, XCircle, Star, Award, X, Send } from "lucide-react";
import "./OrderHistoryPage.css";
import { toast } from "react-toastify";

export default function OrderHistoryPage() {
  const { isAuthenticated } = useAuth();
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [activeFilter, setActiveFilter] = useState("current"); // 'current', 'departed', 'cancelled'

  // Rating modal state
  const [ratingModal, setRatingModal] = useState(null); // { orderId, routeInfo } or null
  const [existingRating, setExistingRating] = useState(null); // fetched rating data
  const [ratingLoading, setRatingLoading] = useState(false);
  const [serviceQuality, setServiceQuality] = useState(5);
  const [punctuality, setPunctuality] = useState(5);
  const [safety, setSafety] = useState(5);
  const [cleanliness, setCleanliness] = useState(5);
  const [description, setDescription] = useState("");
  const [ratingSubmitting, setRatingSubmitting] = useState(false);

  const fetchOrders = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await getRecentOrders();
      setOrders(res.data.result || res.data || []);
    } catch (err) {
      console.error("Fetch recent orders error:", err);
      setError("Không thể tải danh sách đơn hàng. Vui lòng đăng nhập lại!");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (!isAuthenticated) {
      setLoading(false);
      return;
    }
    fetchOrders();
  }, [isAuthenticated]);

  const handleCancelOrder = async (orderId) => {
    if (window.confirm("Bạn có chắc chắn muốn hủy đơn hàng này không?")) {
      try {
        await unholdSeats(orderId);
        toast.success("Đơn hàng đã được hủy thành công!");
        fetchOrders();
      } catch (err) {
        console.error("Cancel order error:", err);
        toast.error("Không thể hủy đơn hàng. Vui lòng thử lại!");
      }
    }
  };

  const openRatingModal = async (order) => {
    setRatingModal({
      orderId: order.orderId,
      routeInfo: `${order.departureProvince} → ${order.destinationProvince}`,
      busCompanyName: order.busCompanyName,
    });
    setExistingRating(null);
    setServiceQuality(5);
    setPunctuality(5);
    setSafety(5);
    setCleanliness(5);
    setDescription("");
    setRatingLoading(true);
    try {
      const res = await getTripRating(order.orderId);
      if (res.data?.result) {
        setExistingRating(res.data.result);
      }
    } catch {
      // No rating yet – show form
    } finally {
      setRatingLoading(false);
    }
  };

  const closeRatingModal = () => {
    setRatingModal(null);
    setExistingRating(null);
  };

  const handleRatingSubmit = async (e) => {
    e.preventDefault();
    if (!ratingModal) return;
    setRatingSubmitting(true);
    try {
      await rateTrip(ratingModal.orderId, {
        serviceQuality,
        punctuality,
        safety,
        cleanliness,
        description,
      });
      toast.success("Cảm ơn bạn đã đánh giá chuyến đi! ⭐");
      closeRatingModal();
    } catch (err) {
      console.error("Submit rating error:", err);
      toast.error("Gửi đánh giá thất bại. Vui lòng thử lại!");
    } finally {
      setRatingSubmitting(false);
    }
  };

  const renderStarSelector = (value, setter, label, icon) => (
    <div className="oh-star-row">
      <span className="oh-star-label">
        {icon} {label}
      </span>
      <div className="oh-star-group">
        {[1, 2, 3, 4, 5].map((star) => (
          <button
            key={star}
            type="button"
            className={`oh-star-btn ${star <= value ? "oh-star-btn--active" : ""}`}
            onClick={() => setter(star)}
            aria-label={`${star} sao`}
          >
            <Star
              size={22}
              fill={star <= value ? "#f59e0b" : "none"}
              color={star <= value ? "#f59e0b" : "#d1d5db"}
            />
          </button>
        ))}
      </div>
    </div>
  );

  if (!isAuthenticated) {
    return (
      <div className="order-history-page">
        <div className="container">
          <div className="breadcrumb text-mono">
            <Link to="/khachhang">Trang chủ</Link> &gt; <span>Đơn hàng của tôi</span>
          </div>

          <BrutalCard className="unauth-orders-card text-center" noHover>
            <div className="unauth-icon-container">
              <div className="unauth-avatar-icon">
                <User size={48} />
              </div>
            </div>
            <h3 className="unauth-title">Bạn chưa đăng nhập</h3>
            <p className="unauth-subtitle">Đăng nhập để xem lịch sử vé 3 tháng gần nhất</p>
            <Link
              to="/khachhang/dang-nhap?redirect=/khachhang/don-hang"
              className="brutal-btn brutal-btn--primary unauth-login-btn text-mono"
            >
              Đăng nhập
            </Link>
          </BrutalCard>
        </div>
      </div>
    );
  }

  const getStatusBadge = (orderStatus) => {
    const s = (orderStatus || "").toUpperCase();

    if (s === "EXPIRED") {
      return <span className="brutal-tag brutal-tag--red">HẾT HẠN</span>;
    }
    if (s === "CANCELLED") {
      return <span className="brutal-tag brutal-tag--red">ĐÃ HỦY</span>;
    }
    if (s === "HOLDING" || s === "PENDING") {
      return <span className="brutal-tag">CHỜ THANH TOÁN</span>;
    }
    if (s === "PAID" || s === "SUCCESS" || s === "SUCCESSFUL" || s === "COMPLETED") {
      return <span className="brutal-tag brutal-tag--green">ĐÃ THANH TOÁN</span>;
    }
    return <span className="brutal-tag brutal-tag--red">KHÔNG XÁC ĐỊNH</span>;
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

  const filteredOrders = orders.filter(order => {
    const status = (order.orderStatus || "").toUpperCase();
    const now = new Date();
    const departureDate = new Date(order.departureTime);

    if (activeFilter === "current") {
      // "Hiện tại": HOLDING/PAID (or similar) and future departureTime
      return (status === "HOLDING" || status === "PAID" || status === "SUCCESS" || status === "SUCCESSFUL" || status === "COMPLETED") && departureDate > now;
    }
    if (activeFilter === "departed") {
      // "Đã đi": ONLY PAID (or similar) and past departureTime
      return (status === "PAID" || status === "SUCCESS" || status === "SUCCESSFUL" || status === "COMPLETED") && departureDate < now;
    }
    if (activeFilter === "cancelled") {
      // "Đã hủy": EXPIRED or CANCELLED
      return status === "EXPIRED" || status === "CANCELLED";
    }
    return false; // Should not happen if activeFilter is always one of the above
  });

  return (
    <>
    <div className="order-history-page">
      <div className="container">
        <div className="order-history-header">
          <h2 className="section-title" style={{ left: 0, transform: "none", display: "flex", alignItems: "center", gap: "0.5rem" }}>
            <ClipboardList size={28} /> Lịch sử đơn hàng
          </h2>
        </div>

        <div className="order-filters">
          <BrutalButton
            variant={activeFilter === "current" ? "primary" : "secondary"}
            onClick={() => setActiveFilter("current")}
            size="small"
          >
            Hiện tại
          </BrutalButton>
          <BrutalButton
            variant={activeFilter === "departed" ? "primary" : "secondary"}
            onClick={() => setActiveFilter("departed")}
            size="small"
          >
            Đã đi
          </BrutalButton>
          <BrutalButton
            variant={activeFilter === "cancelled" ? "primary" : "secondary"}
            onClick={() => setActiveFilter("cancelled")}
            size="small"
          >
            Đã hủy
          </BrutalButton>
        </div>

        {loading ? (
          <div className="page-loader">
            <div className="brutal-spinner"></div>
            <p>Đang tải lịch sử đặt vé...</p>
          </div>
        ) : error ? (
          <BrutalCard className="error-card text-center">
            <h3>Đã xảy ra lỗi</h3>
            <p>{error}</p>
          </BrutalCard>
        ) : filteredOrders.length === 0 ? (
          <BrutalCard className="empty-orders-card text-center" noHover>
            <h3>Không có đơn hàng nào trong mục này!</h3>
            <p>Hãy thử chọn một bộ lọc khác hoặc đặt vé ngay.</p>
            <Link to="/khachhang" className="brutal-btn brutal-btn--primary" style={{ marginTop: "1.5rem", display: "inline-block" }}>
              ĐẶT VÉ NGAY
            </Link>
          </BrutalCard>
        ) : (
          <div className="orders-list">
            {filteredOrders.map((order) => (
              <BrutalCard key={order.orderId} className="history-order-card">
                <div className="order-card-header">
                  <span className="order-id text-mono">Mã đơn: #{order.orderId}</span>
                  {getStatusBadge(order.orderStatus)}
                </div>

                <div className="order-card-body">
                  <div className="order-route">
                    <span className="route-province">{order.departureProvince}</span>
                    <ArrowRight size={18} />
                    <span className="route-province">{order.destinationProvince}</span>
                  </div>

                  <div className="order-meta">
                    <div className="order-meta-item">
                      <Calendar size={14} />
                      <span className="text-mono">{formatDate(order.departureTime)}</span>
                    </div>
                    <div className="order-meta-item">
                      <Clock size={14} />
                      <span className="text-mono">{formatTime(order.departureTime)}</span>
                    </div>
                    <div className="order-company brutal-tag">{order.busCompanyName}</div>
                  </div>
                </div>

                <div className="order-card-footer">
                  <div className="order-price">
                    <span className="price-label">Tổng tiền:</span>
                    <span className="price-value text-mono">
                      {new Intl.NumberFormat("vi-VN").format(order.totalCost)}đ
                    </span>
                  </div>
                  <div className="order-card-actions">
                    {/* Cancel button for pending orders */}
                    {(order.orderStatus === "HOLDING" || order.orderStatus === "PENDING") && (
                      <BrutalButton
                        variant="danger"
                        onClick={() => handleCancelOrder(order.orderId)}
                        size="small"
                        className="cancel-order-btn"
                      >
                        <XCircle size={14} /> HỦY
                      </BrutalButton>
                    )}
                    {/* Rating button for departed orders */}
                    {activeFilter === "departed" && (
                      <BrutalButton
                        variant="secondary"
                        onClick={() => openRatingModal(order)}
                        size="small"
                        className="rate-order-btn"
                        id={`btn-rate-order-${order.orderId}`}
                      >
                        <Star size={14} /> ĐÁNH GIÁ
                      </BrutalButton>
                    )}
                    <Link
                      to={`/khachhang/don-hang/${order.orderId}`}
                      className="brutal-btn"
                      id={`btn-detail-order-${order.orderId}`}
                    >
                      <Info size={14} /> CHI TIẾT
                    </Link>
                  </div>
                </div>
              </BrutalCard>
            ))}
          </div>
        )}
      </div>
    </div>

    {/* ===== Rating Modal ===== */}
    {ratingModal && (
      <div className="oh-modal-overlay" onClick={closeRatingModal}>
        <div className="oh-modal" onClick={(e) => e.stopPropagation()}>
          {/* Header */}
          <div className="oh-modal-header">
            <div className="oh-modal-title-area">
              <div className="oh-modal-icon">
                <Award size={22} />
              </div>
              <div>
                <h3 className="oh-modal-title">Đánh giá chuyến đi</h3>
                <p className="oh-modal-subtitle">{ratingModal.routeInfo} · {ratingModal.busCompanyName}</p>
              </div>
            </div>
            <button className="oh-modal-close" onClick={closeRatingModal} aria-label="Đóng">
              <X size={20} />
            </button>
          </div>

          {/* Body */}
          <div className="oh-modal-body">
            {ratingLoading ? (
              <div className="oh-modal-loading">
                <div className="brutal-spinner" />
                <p>Đang kiểm tra đánh giá...</p>
              </div>
            ) : existingRating ? (
              /* === Show existing rating === */
              <div className="oh-existing-rating">
                <div className="oh-avg-badge">
                  <Star size={28} fill="#f59e0b" color="#f59e0b" />
                  <span className="oh-avg-num">{existingRating.averageStars?.toFixed(1)}</span>
                  <span className="oh-avg-total">/ 5.0</span>
                </div>
                <p className="oh-already-label">Bạn đã đánh giá chuyến này rồi</p>

                <div className="oh-breakdown">
                  {[
                    { label: "🎯 Chất lượng dịch vụ", val: existingRating.serviceQuality },
                    { label: "⏱ Đúng giờ", val: existingRating.punctuality },
                    { label: "🛡 An toàn", val: existingRating.safety },
                    { label: "✨ Vệ sinh", val: existingRating.cleanliness },
                  ].map(({ label, val }) => (
                    <div key={label} className="oh-breakdown-row">
                      <span>{label}</span>
                      <div className="oh-breakdown-stars">
                        {[1,2,3,4,5].map(s => (
                          <Star key={s} size={16}
                            fill={s <= val ? "#f59e0b" : "none"}
                            color={s <= val ? "#f59e0b" : "#d1d5db"}
                          />
                        ))}
                        <span className="oh-breakdown-num">{val} ★</span>
                      </div>
                    </div>
                  ))}
                </div>

                {existingRating.description && (
                  <div className="oh-comment-box">
                    <span className="oh-comment-label">Nhận xét của bạn</span>
                    <p className="oh-comment-text">"{existingRating.description}"</p>
                  </div>
                )}

                <p className="oh-rated-at">
                  Đánh giá lúc {new Date(existingRating.createdAt).toLocaleString("vi-VN")}
                </p>
              </div>
            ) : (
              /* === Rating form === */
              <form onSubmit={handleRatingSubmit} className="oh-rating-form">
                <p className="oh-form-intro">Hãy cho chúng tôi biết trải nghiệm của bạn!</p>

                <div className="oh-stars-section">
                  {renderStarSelector(serviceQuality, setServiceQuality, "Chất lượng dịch vụ", "🎯")}
                  {renderStarSelector(punctuality, setPunctuality, "Đúng giờ", "⏱")}
                  {renderStarSelector(safety, setSafety, "An toàn", "🛡")}
                  {renderStarSelector(cleanliness, setCleanliness, "Vệ sinh", "✨")}
                </div>

                <div className="oh-desc-field">
                  <label className="oh-desc-label">Lời nhắn (không bắt buộc)</label>
                  <textarea
                    className="brutal-input oh-desc-textarea"
                    rows={3}
                    placeholder="Chia sẻ trải nghiệm của bạn về chuyến xe này..."
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                  />
                </div>

                <button
                  type="submit"
                  className={`brutal-btn brutal-btn--primary oh-submit-btn ${ratingSubmitting ? "oh-submit-btn--loading" : ""}`}
                  disabled={ratingSubmitting}
                >
                  {ratingSubmitting ? (
                    <><div className="oh-btn-spinner" /> Đang gửi...</>
                  ) : (
                    <><Send size={16} /> GỬI ĐÁNH GIÁ</>
                  )}
                </button>
              </form>
            )}
          </div>
        </div>
      </div>
    )}
    </>
  );
}
