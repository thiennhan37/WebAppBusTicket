import React from 'react';

const SeatMap = ({ onSeatClick }) => {
  // 1. Data giả lập theo cấu trúc 3 chiều bạn cung cấp
  const busData = {
    name: "Xe giường nằm",
    diagram: {
      floor: 2,
      row: 6,
      column: 3,
      seatList: [
        // Tầng 1 (Tầng Dưới)
        [
          [{ id: "A1", status: "booked" }, { id: "A2", status: "available" }, { id: "A3", status: "available" }],
          [{ id: "A4", status: "available" }, { id: "A5", status: "booked" }, { id: "A6", status: "available" }],
          [{ id: "A7", status: "available" }, { id: "A8", status: "available" }, { id: "A9", status: "available" }],
          [{ id: "A10", status: "booked" }, { id: "A11", status: "available" }, { id: "A12", status: "available" }],
          [{ id: "A13", status: "available" }, { id: "A14", status: "available" }, { id: "A15", status: "available" }],
          [{ id: "A16", status: "available" }, { id: "A17", status: "available" }, { id: "A18", status: "available" }]
        ],
        // Tầng 2 (Tầng Trên)
        [
          [{ id: "B1", status: "available" }, { id: "B2", status: "available" }, { id: "B3", status: "available" }],
          [{ id: "B4", status: "available" }, { id: "B5", status: "available" }, { id: "B6", status: "booked" }],
          [{ id: "B7", status: "available" }, { id: "B8", status: "available" }, { id: "B9", status: "available" }],
          [{ id: "B10", status: "available" }, { id: "B11", status: "available" }, { id: "B12", status: "available" }],
          [{ id: "B13", status: "available" }, { id: "B14", status: "available" }, { id: "B15", status: "available" }],
          [{ id: "B16", status: "available" }, { id: "B17", status: "available" }, { id: "B18", status: "available" }]
        ]
      ]
    }
  };

  return (
    <div className="bg-white-50 min-h-screen">
      <div className="max-w-5xl mx-auto">
        {/* Bố cục 2 cột cho 2 tầng */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
          {busData.diagram.seatList.map((floor, floorIndex) => (
            <div key={floorIndex} className="bg-white p-4 rounded-xl shadow-sm border border-gray-300">
              {/* Tiêu đề tầng */}
              <div className="text-center font-bold text-gray-600 mb-6 pb-2 border-b uppercase tracking-wider">
                {floorIndex === 0 ? "Tầng Dưới" : "Tầng Trên"}
              </div>

              {/* Lưới ghế giữ nguyên style cũ của bạn */}
              <div 
                className="grid gap-4"
                style={{ 
                  gridTemplateColumns: `repeat(${busData.diagram.column}, minmax(0, 1fr))` 
                }}
              >
                {/* Duyệt mảng 3 chiều: Tầng -> Hàng -> Ghế */}
                {floor.map((row) => 
                  row.map((seat) => (
                    <div
                      key={seat.id}
                      onClick={() => onSeatClick(seat)}
                      className={`relative h-[120px] rounded-lg border-2 p-2 cursor-pointer transition-all duration-200 ${
                        seat.status === 'booked'
                          ? 'bg-red-50 border-red-200 hover:border-red-400'
                          : 'bg-white border-gray-200 hover:border-blue-400 hover:shadow-md'
                      }`}
                    >
                      <span className={`font-semibold ${seat.status === 'booked' ? 'text-red-700' : 'text-gray-700'}`}>
                        {seat.id}
                      </span>
                      
                      {seat.status === 'booked' && (
                        <div className="absolute bottom-2 left-2 right-2 text-[10px] text-red-600 bg-red-100 px-1 py-0.5 rounded text-center truncate font-medium">
                          Đã đặt
                        </div>
                      )}
                    </div>
                  ))
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