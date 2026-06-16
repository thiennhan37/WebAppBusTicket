import { Link } from "react-router-dom";
import { Star } from "lucide-react";
import "./TripCard.css";

export default function TripCard({ trip }) {
  const formatPrice = (price) => {
    return new Intl.NumberFormat("vi-VN").format(price);
  };

  return (
    <div className="trip-card" id={`trip-${trip.tripId}`}>
      <div className="trip-card__main">
        <div className="trip-card__header">
          <span className="trip-card__company">{trip.busCompanyName}</span>
          <span className="trip-card__bus-type">{trip.busType}</span>
        </div>

        <div className="trip-card__time-route">
          <span className="trip-card__time">{trip.departureTime}</span>
          <div className="trip-card__arrow">
            <div className="trip-card__duration">{trip.duration}</div>
            <div className="trip-card__arrow-line"></div>
          </div>
          <span className="trip-card__time">{trip.arrivalTime}</span>
        </div>

        <div className="trip-card__stations">
          <span>{trip.departureStation}</span>
          <span>{trip.arrivalStation}</span>
        </div>

        <div className="trip-card__meta">
          <span className="trip-card__rating">
            <Star size={14} className="trip-card__rating-star" fill="#FFE600" />
            {trip.rating?.toFixed(1) || "N/A"}
            <span style={{ color: "var(--color-gray-400)", fontWeight: 400 }}>
              ({trip.reviewCount || 0})
            </span>
          </span>
          <span
            className={`trip-card__seats ${
              trip.availableSeats <= 5 ? "trip-card__seats--low" : ""
            }`}
          >
            {trip.availableSeats} ghế trống
          </span>
        </div>
      </div>

      <div className="trip-card__action">
        <div>
          <div className="trip-card__price">{formatPrice(trip.price)}đ</div>
          <div className="trip-card__price-unit">/ghế</div>
        </div>
        <Link
          to={`/khachhang/chon-ghe/${trip.tripId}`}
          className="brutal-btn brutal-btn--primary"
          id={`btn-select-trip-${trip.tripId}`}
        >
          CHỌN CHUYẾN
        </Link>
      </div>
    </div>
  );
}
