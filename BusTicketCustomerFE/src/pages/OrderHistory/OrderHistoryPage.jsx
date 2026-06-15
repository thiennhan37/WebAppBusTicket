import React, { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { getRecentOrders } from "../../services/orderService";
import { useAuth } from "../../context/AuthContext";
import BrutalCard from "../../components/BrutalCard";
import BrutalButton from "../../components/BrutalButton";
import { ClipboardList, ArrowRight, Calendar, Info, Clock, User } from "lucide-react";
import "./OrderHistoryPage.css";

export default function OrderHistoryPage() {
  const { isAuthenticated } = useAuth();
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!isAuthenticated) {
      setLoading(false);
      return;
    }
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

    fetchOrders();
  }, [isAuthenticated]);

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

  const getStatusBadge = (status) => {
    const s = (status || "").toUpperCase();
    if (s === "PAID" || s === "SUCCESS" || s === "SUCCESSFUL" || s === "COMPLETED") {
      return <span className="brutal-tag brutal-tag--green">ĐÃ THANH TOÁN</span>;
    }
    if (s === "PENDING" || s === "HOLDING") {
      return <span className="brutal-tag">CHỜ THANH TOÁN</span>;
    }
    return <span className="brutal-tag brutal-tag--red">ĐÃ HỦY</span>;
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
    <div className="order-history-page">
      <div className="container">
        <div className="order-history-header">
          <h2 className="section-title" style={{ left: 0, transform: "none", display: "flex", alignItems: "center", gap: "0.5rem" }}>
            <ClipboardList size={28} /> Lịch sử đơn hàng
          </h2>
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
        ) : orders.length === 0 ? (
          <BrutalCard className="empty-orders-card text-center" noHover>
            <h3>Bạn chưa đặt vé nào!</h3>
            <p>Hãy bắt đầu tìm kiếm chuyến đi và trải nghiệm dịch vụ của chúng tôi.</p>
            <Link to="/khachhang" className="brutal-btn brutal-btn--primary" style={{ marginTop: "1.5rem", display: "inline-block" }}>
              ĐẶT VÉ NGAY
            </Link>
          </BrutalCard>
        ) : (
          <div className="orders-list">
            {orders.map((order) => (
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
                  <Link
                    to={`/khachhang/don-hang/${order.orderId}`}
                    className="brutal-btn"
                    id={`btn-detail-order-${order.orderId}`}
                  >
                    <Info size={14} /> CHI TIẾT
                  </Link>
                </div>
              </BrutalCard>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
