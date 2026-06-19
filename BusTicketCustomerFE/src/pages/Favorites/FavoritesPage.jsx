import React, { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import BrutalCard from "../../components/BrutalCard";
import { Heart, MapPin, Calendar, Clock, Armchair } from "lucide-react";
import { toast } from "sonner";
import "./FavoritesPage.css";

export default function FavoritesPage() {
  const [favorites, setFavorites] = useState([]);

  useEffect(() => {
    loadFavorites();
  }, []);

  const loadFavorites = () => {
    const stored = JSON.parse(localStorage.getItem("favoriteTrips") || "[]");
    setFavorites(stored);
  };

  const removeFavorite = (bookingOrderId) => {
    const updated = favorites.filter((f) => f.bookingOrderId !== bookingOrderId);
    localStorage.setItem("favoriteTrips", JSON.stringify(updated));
    setFavorites(updated);
    toast.success("Đã xóa khỏi danh sách yêu thích");
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
    <div className="favorites-page">
      <div className="container">
        <h2 className="page-title">
          <Heart size={28} fill="#e74c3c" color="#e74c3c" />
          Chuyến đi yêu thích
        </h2>
        <p className="page-subtitle">
          {favorites.length > 0 ? (
            <>
              Bạn có <span className="favorites-count-badge">{favorites.length}</span> chuyến đi đã lưu
            </>
          ) : (
            "Lưu lại những chuyến đi bạn quan tâm để xem lại sau"
          )}
        </p>

        {favorites.length === 0 ? (
          <BrutalCard className="favorites-empty" noHover>
            <Heart size={64} className="favorites-empty-icon" />
            <h3>Chưa có chuyến đi yêu thích</h3>
            <p>
              Nhấn vào biểu tượng trái tim ở trang chi tiết đơn hàng để lưu chuyến đi vào đây.
            </p>
            <Link to="/khachhang/don-hang" className="brutal-btn brutal-btn--primary">
              XEM ĐƠN HÀNG CỦA TÔI
            </Link>
          </BrutalCard>
        ) : (
          <div className="favorites-grid">
            {favorites.map((fav) => (
              <BrutalCard key={fav.bookingOrderId} className="fav-card" noHover>
                <div className="fav-card-header">
                  <div>
                    <div className="fav-card-company">
                      {fav.busCompanyName} • {fav.busType}
                    </div>
                    <div className="fav-card-order-id">
                      Đơn #{fav.bookingOrderId}
                    </div>
                  </div>
                  <button
                    className="fav-card-remove"
                    onClick={() => removeFavorite(fav.bookingOrderId)}
                    title="Bỏ yêu thích"
                  >
                    <Heart size={18} fill="#e74c3c" color="#e74c3c" />
                  </button>
                </div>

                <div className="fav-card-route">
                  <div className="fav-route-point">
                    <MapPin size={16} />
                    <span>{fav.pickupProvince}</span>
                  </div>
                  <span className="fav-route-arrow">→</span>
                  <div className="fav-route-point">
                    <MapPin size={16} />
                    <span>{fav.dropoffProvince}</span>
                  </div>
                </div>

                <div className="fav-card-meta">
                  <div className="fav-meta-item">
                    <Calendar size={14} />
                    {formatDate(fav.departureTime)}
                  </div>
                  <div className="fav-meta-item">
                    <Clock size={14} />
                    {formatTime(fav.departureTime)}
                  </div>
                  <div className="fav-meta-item">
                    <Armchair size={14} />
                    {fav.seatCount} ghế
                  </div>
                </div>

                <div className="fav-card-footer">
                  <span className="fav-card-price">
                    {new Intl.NumberFormat("vi-VN").format(fav.totalAmount || 0)}đ
                  </span>
                  <Link
                    to={`/khachhang/don-hang/${fav.bookingOrderId}`}
                    className="fav-card-view-link"
                  >
                    Xem chi tiết →
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
