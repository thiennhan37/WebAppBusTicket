import React from "react";
import "./SeatMap.css";

export default function SeatMap({
  seats = [],
  diagram = null,
  busTypeName = "", // Re-add busTypeName prop
  selectedSeats = [],
  onSeatSelect,
}) {
  // Map seatCode to full seat object for easy lookup
  const seatMap = new Map(seats.map((seat) => [seat.seatCode, seat]));

  const getSeatClass = (seat) => {
    let className = "";
    if (selectedSeats.includes(seat.seatId)) {
      className = "selecting";
    } else if (seat.status === "BOOKED") {
      className = "booked";
    } else if (seat.status === "HELD") {
      className = "held"; // Add held class
    } else {
      className = "available";
    }
    return `seat ${className}`;
  };

  const handleClick = (seat) => {
    if (seat.status === "BOOKED" || seat.status === "HELD") return;
    onSeatSelect?.(seat);
  };

  // Steering wheel SVG
  const SteeringWheelSVG = () => (
    <svg className="steering-wheel" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <circle cx="12" cy="12" r="10"></circle>
      <line x1="12" y1="2" x2="12" y2="22"></line>
      <line x1="2" y1="12" x2="22" y2="12"></line>
    </svg>
  );

  if (!diagram || !diagram.seatList || diagram.seatList.length === 0) {
    return <div className="seat-map-empty">Không có sơ đồ ghế để hiển thị.</div>;
  }

  return (
    <div className="seat-map-wrapper">
      <div className="seat-map__title">Sơ đồ chỗ ngồi</div>
      {busTypeName && (
        <div className="seat-map__bus-type">Loại xe: {busTypeName}</div>
      )}

      <div className="bus-container">
        {diagram.seatList.map((deckLayout, deckIndex) => {
          const deckNumber = deckIndex + 1; // 0-indexed to 1-indexed
          const deckTitle = deckNumber === 1 ? "Tầng dưới" : "Tầng trên";

          return (
            <div className="deck" key={deckNumber}>
              <div className="deck-title">{deckTitle}</div>
              <div className="deck-body">
                {deckNumber === 1 && ( // Only show steering wheel for the first deck
                  <div className="driver-row">
                    <SteeringWheelSVG />
                  </div>
                )}
                {deckNumber === 2 && ( // Placeholder for alignment in the second deck
                  <div className="driver-row" style={{ visibility: "hidden" }}>
                    <div style={{ height: "32px" }}></div>
                  </div>
                )}

                <div className="seats-grid">
                  {deckLayout.flat().map((seatCode, index) => {
                    if (!seatCode) {
                      return <div key={`empty-${deckNumber}-${index}`} className="empty-space"></div>;
                    }
                    const seat = seatMap.get(seatCode);
                    if (!seat) {
                      // If seat data is missing for a code in the diagram, render as unavailable or empty
                      return <div key={`missing-${seatCode}-${index}`} className="empty-space"></div>;
                    }

                    return (
                      <div
                        key={seat.seatId}
                        className={getSeatClass(seat)}
                        onClick={() => handleClick(seat)}
                        title={`${seat.seatCode} - ${
                          seat.status === "AVAILABLE"
                            ? "Trống"
                            : seat.status === "BOOKED"
                            ? "Đã đặt"
                            : "Đang giữ"
                        }`}
                        id={`seat-${seat.seatCode}`}
                      >
                        {seat.seatCode}
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Legend */}
      <div className="seat-map__legend">
        <div className="seat-map__legend-item">
          <div className="seat-map__legend-box seat-map__legend-box--available"></div>
          Trống
        </div>
        <div className="seat-map__legend-item">
          <div className="seat-map__legend-box seat-map__legend-box--selecting"></div>
          Đang chọn
        </div>
        <div className="seat-map__legend-item">
          <div className="seat-map__legend-box seat-map__legend-box--booked"></div>
          Đã đặt
        </div>
        <div className="seat-map__legend-item">
          <div className="seat-map__legend-box seat-map__legend-box--held"></div>
          Đang giữ
        </div>
      </div>
    </div>
  );
}
