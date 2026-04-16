import React, { useState } from 'react';

const Ticket = () => {
//   // Mock dữ liệu ghế (1: Trống, 2: Đã đặt)
//   const [seats, setSeats] = useState(
//     Array.from({ length: 36 }, (_, i) => ({
//       id: `A${i + 1}`,
//       status: Math.random() > 0.7 ? 'booked' : 'available', 
//     }))
//   );

//   const [selectedSeats, setSelectedSeats] = useState([]);
//   const []
//   // Hàm chọn/bỏ chọn nhiều ghế
//   const toggleSeat = (seatId, status) => {
//     if (status === 'booked') return; // Không cho chọn ghế đã đặt
//     if (selectedSeats.includes(seatId)) {
//       setSelectedSeats(selectedSeats.filter(id => id !== seatId));
//     } else {
//       setSelectedSeats([...selectedSeats, seatId]);
//     }
//   };

  return (
    <>
    </>
//     <div className="min-h-screen bg-gray-50 p-6 font-sans">
//       {/* Header */}
//       <div className="mb-6 flex justify-between items-center">
//         <div>
//           <h1 className="text-2xl font-bold text-gray-800">Quản lý đặt vé</h1>
//           <p className="text-sm text-gray-500 mt-1">Hệ thống quản lý vé và sơ đồ ghế VEXEDAT</p>
//         </div>
//         <div className="flex gap-3">
//           <button className="px-4 py-2 bg-white border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors shadow-sm font-medium">
//             Tải lại
//           </button>
//         </div>
//       </div>

//       {/* 1. Bộ lọc (Tương tự thiết kế ở ảnh 2) */}
//       <div className="bg-white p-5 rounded-xl shadow-sm mb-6 border border-gray-100">
//         <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
//           <div>
//             <label className="block text-xs font-semibold text-gray-500 uppercase mb-2">Nơi đi</label>
//             <select className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm">
//               <option>Bến xe Nước Ngầm</option>
//               <option>Bến xe Miền Đông</option>
//             </select>
//           </div>
//           <div>
//             <label className="block text-xs font-semibold text-gray-500 uppercase mb-2">Nơi đến</label>
//             <select className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm">
//               <option>Bến xe Hà Tĩnh</option>
//               <option>Bến xe Đà Nẵng</option>
//             </select>
//           </div>
//           <div>
//             <label className="block text-xs font-semibold text-gray-500 uppercase mb-2">Ngày khởi hành</label>
//             <input type="date" className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm" />
//           </div>
//           <div>
//             <label className="block text-xs font-semibold text-gray-500 uppercase mb-2">Giờ xuất bến</label>
//             <select className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm">
//               <option>09:30</option>
//               <option>10:45</option>
//               <option>21:00</option>
//             </select>
//           </div>
//         </div>
//       </div>

//       {/* 2. Thông tin chuyến & Nút thao tác */}
//       <div className="bg-white p-5 rounded-xl shadow-sm mb-6 border border-gray-100 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
//         <div>
//           <h2 className="text-lg font-semibold text-emerald-700 mb-1">Chuyến 09:30 ngày 30/04/2026 tuyến Nước Ngầm - Hà Tĩnh</h2>
//           <div className="flex gap-6 text-sm text-gray-600 mt-2">
//             <p><span className="font-medium">Loại xe:</span> Giường nằm 40 chỗ VIP</p>
//             <p><span className="font-medium">Ghế trống:</span> {seats.filter(s => s.status === 'available').length}/36</p>
//             <p><span className="font-medium">Biển số:</span> 29B-123.45</p>
//           </div>
//         </div>
//         <div className="flex gap-3">
//           <button 
//              disabled={selectedSeats.length === 0}
//              className="px-5 py-2.5 bg-red-500 text-white rounded-lg hover:bg-red-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors shadow-sm font-medium flex items-center gap-2">
//             <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
//             Hủy vé đã chọn
//           </button>
//           <button 
//              disabled={selectedSeats.length === 0}
//              className="px-5 py-2.5 bg-emerald-600 text-white rounded-lg hover:bg-emerald-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors shadow-sm font-medium flex items-center gap-2">
//             <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" /></svg>
//             Thêm vé ({selectedSeats.length})
//           </button>
//         </div>
//       </div>

//       {/* 3. Sơ đồ ghế ngồi */}
//       <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
//         <div className="flex justify-between items-center mb-6">
//           <h3 className="text-md font-bold text-gray-800 uppercase">Sơ đồ tầng 1</h3>
//           <div className="flex gap-4 text-sm">
//             <div className="flex items-center gap-2"><div className="w-4 h-4 border border-emerald-500 rounded bg-emerald-50"></div> <span className="text-gray-600">Trống</span></div>
//             <div className="flex items-center gap-2"><div className="w-4 h-4 border border-emerald-600 rounded bg-emerald-600"></div> <span className="text-gray-600">Đang chọn</span></div>
//             <div className="flex items-center gap-2"><div className="w-4 h-4 border border-gray-300 rounded bg-gray-200"></div> <span className="text-gray-600">Đã đặt</span></div>
//           </div>
//         </div>

//         {/* Grid ghế: 2 dãy, mỗi dãy 2 ghế, ở giữa là lối đi */}
//         <div className="grid grid-cols-5 gap-y-4 gap-x-2 max-w-3xl mx-auto">
//           {seats.map((seat, index) => {
//             const isSelected = selectedSeats.includes(seat.id);
//             const isBooked = seat.status === 'booked';
            
//             // Xử lý chèn lối đi ở cột giữa (cột 3)
//             const isAisle = (index % 4) === 2; 
            
//             return (
//               <React.Fragment key={seat.id}>
//                 {isAisle && <div className="w-8"></div> /* Lối đi giữa */}
//                 <button
//                   onClick={() => toggleSeat(seat.id, seat.status)}
//                   disabled={isBooked}
//                   className={`
//                     relative h-20 rounded-xl border-2 flex items-center justify-center transition-all duration-200
//                     ${isBooked ? 'bg-gray-100 border-gray-200 text-gray-400 cursor-not-allowed' : 
//                       isSelected ? 'bg-emerald-600 border-emerald-600 text-white shadow-md transform scale-105' : 
//                       'bg-emerald-50 border-emerald-500 text-emerald-700 hover:bg-emerald-100 cursor-pointer'}
//                   `}
//                 >
//                   <span className="font-bold">{seat.id}</span>
//                   {/* Icon minh họa vô lăng cho ghế tài xế nếu cần có thể thêm logic ở đây */}
//                 </button>
//               </React.Fragment>
//             );
//           })}
//         </div>
//       </div>
    // </div>
  );
};

export default Ticket;