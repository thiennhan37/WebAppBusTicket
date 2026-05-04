import React from 'react';
import {Phone} from 'lucide-react';
const SeatMap = ({ busType, seatMap, onSeatClick, mode = "normal", selectedSeatsList = [] }) => {
  // Logic mapping dữ liệu
  const processedFloors = React.useMemo(() => {
    if (!busType?.diagram?.seatList || !seatMap) return [];
    
    const seatDataMap = new Map(seatMap.map(item => [item.seat, item]));

    return busType.diagram.seatList.map((floor) => 
      floor.map((row) => 
        row.map((seatName) => {
          if (!seatName) return null;
          const detail = seatDataMap.get(seatName);
          return {
            seatName: seatName,
            ...detail
          };
        })
      )
    );
  }, [busType, seatMap]);
  // console.log(processedFloors);

  const formatter = new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  });
  return (
    <div className="bg-white-50 min-h-screen">
      <div className="max-w-5xl mx-auto">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
          {processedFloors.map((floor, floorIndex) => (
            <div key={floorIndex} className="bg-white p-2 rounded-xl shadow-sm border border-gray-300">
              <div className="text-center font-bold text-gray-600 mb-6 pb-2 border-b uppercase tracking-wider">
                {floorIndex === 0 ? "Tầng 1" : "Tầng 2"}
              </div>

              <div 
                className="grid gap-1"
                style={{ 
                  // Sử dụng column từ busType truyền vào
                  gridTemplateColumns: `repeat(${busType.diagram.column}, minmax(0, 1fr))` 
                }}
              >
                {floor.map((row, rowIndex) => 
                  row.map((seat, colIndex) => {
                    // Nếu là null (lối đi) thì render khoảng trống
                    if (!seat) return <div key={`empty-${rowIndex}-${colIndex}`} />;

                    // Mapping status từ API sang màu sắc giao diện
                    const isBooked = seat.status === 'BOOKED';
                    const isHeld = seat.status === 'HELD';
                    const isAvailable = seat.status === 'AVAILABLE';
                    const isSelected = selectedSeatsList.some(s => s.id === seat.id);

                    let bgClass = '';
                    if (isSelected) {
                      bgClass = 'bg-blue-300 border-blue-600 shadow-[0_0_10px_rgba(37,99,235,0.5)] transform scale-[1.02]';
                    } else if (isBooked) {
                      bgClass = 'bg-green-200 border-green-500 hover:bg-green-400';
                    } else if (isHeld) {
                      bgClass = 'bg-yellow-200 border-yellow-500 hover:bg-yellow-400';
                    } else {
                      bgClass = 'bg-white border-gray-200 hover:border-blue-500';
                    }

                    let cursorClass = 'cursor-pointer';
                    if (mode === 'normal' && isAvailable) cursorClass = 'cursor-default pointer-events-none opacity-80';
                    if (mode === 'book' && !isAvailable) cursorClass = 'cursor-not-allowed opacity-60';
                    if (mode === 'cancel' && isAvailable) cursorClass = 'cursor-not-allowed opacity-60';

                    return (
                      <div
                        key={seat.id}
                        onClick={() => onSeatClick && onSeatClick(seat)} 
                        className={`relative h-[120px] rounded-lg border-2 p-1 transition-all duration-200 ${cursorClass} ${bgClass}`}
                      >
                        <div className="flex items-center gap-1">
                          <span className={`font-semibold text-black`}>{seat.seatName}</span>
                          {!isAvailable && <Phone size={15} />}
                          <span className={`font-semibold text-black text-xs`}>{` ${seat?.ticket?.bookingOrder?.customerPhone || ""}`}</span>
                        </div>
                        {/* Bạn có thể truy cập seat.ticket hoặc seat.id ở đây */}
                        {!isAvailable && (
                          <div>
                            <div className="text-[10px] text-black font-bold">
                              {seat.ticket?.bookingOrder?.customerName || "Đã đặt"}
                            </div>
                            <div className="text-[10px] text-green-600 font-bold">
                              {`Giá vé: ${seat.ticket?.price ? formatter.format(seat.ticket?.price) : "Đã đặt"}`}
                            </div>
                            <div className="text-[10px] text-blue-600 font-bold">
                              {`Đón: ${seat.ticket?.arrivalStop || "Chưa có"}`}
                            </div>
                            <div className="text-[10px] text-red-600 font-bold">
                              {`Trả: ${seat.ticket?.destinationStop || "Chưa có"}`}
                            </div>
                          </div>
                        )}
                      </div>
                    );
                  })
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default SeatMap;