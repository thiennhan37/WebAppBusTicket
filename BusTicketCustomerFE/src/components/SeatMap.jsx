import "./SeatMap.css";

export default function SeatMap({
  seats = [],
  busTypeName = "",
  selectedSeats = [],
  onSeatSelect,
}) {
  const getSeatClass = (seat) => {
    if (selectedSeats.includes(seat.seatId)) return "seat-map__seat--selected";
    if (seat.status === "BOOKED") return "seat-map__seat--booked";
    if (seat.status === "HELD") return "seat-map__seat--held";
    return "seat-map__seat--available";
  };

  const handleClick = (seat) => {
    if (seat.status === "BOOKED" || seat.status === "HELD") return;
    onSeatSelect?.(seat);
  };

  return (
    <div className="seat-map">
      <div className="seat-map__title">Sơ đồ chỗ ngồi</div>
      {busTypeName && (
        <div className="seat-map__bus-type">Loại xe: {busTypeName}</div>
      )}

      <div className="seat-map__grid">
        {seats.map((seat) => (
          <div
            key={seat.seatId}
            className={`seat-map__seat ${getSeatClass(seat)}`}
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
        ))}
      </div>

      <div className="seat-map__legend">
        <div className="seat-map__legend-item">
          <div className="seat-map__legend-box seat-map__legend-box--available"></div>
          Trống
        </div>
        <div className="seat-map__legend-item">
          <div className="seat-map__legend-box seat-map__legend-box--selected"></div>
          Đang chọn
        </div>
        <div className="seat-map__legend-item">
          <div className="seat-map__legend-box seat-map__legend-box--booked"></div>
          Đã đặt
        </div>
      </div>
    </div>
  );
}
