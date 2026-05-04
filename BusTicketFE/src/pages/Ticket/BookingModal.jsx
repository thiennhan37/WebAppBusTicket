import React, { useState, useEffect } from 'react';
import { X, User, Phone, Mail, MapPin, Banknote, CreditCard, Timer } from 'lucide-react'; 
import { useQuery } from '@tanstack/react-query';
import RouteService from '../../Services/routeService';
import ConfirmModal from "../../components/other/ConfirmModal"

const BookingModal = ({bookingOrderId, selectedTrip, selectedSeatsList, onClose, onConfirm }) => {
  const [formData, setFormData] = useState({
    customerName: '',
    customerPhone: '',
    customerEmail: '',
    arrivalId: '',
    destinationId: ''
  });



  // 2. Logic đếm ngược
  const holdingTime = 600;
  const [endTime] = useState(() => Date.now() + holdingTime * 1000); // 300 giây từ lúc này
  const [timeLeft, setTimeLeft] = useState(holdingTime);
  const [showExitConfirm, setShowExitConfirm] = useState(false);

  // 2. Logic đếm ngược mới
  useEffect(() => {
    const timer = setInterval(() => {
      const now = Date.now();
      const remaining = Math.round((endTime - now) / 1000);

      if (remaining <= 0) {
        setTimeLeft(0);
        clearInterval(timer);
        onClose(); // Tự động đóng khi hết thời gian
      } else {
        setTimeLeft(remaining);
      }
    }, 500); // Chạy 500ms một lần để cập nhật mượt mà hơn, không sợ tốn tài nguyên

    return () => clearInterval(timer);
  }, [endTime, onClose]);

  const formatTime = (seconds) => {
    const totalSeconds = Math.max(0, seconds); // Đảm bảo không âm
    const mins = Math.floor(totalSeconds / 60);
    const secs = totalSeconds % 60;
    return `${mins}:${secs < 10 ? '0' : ''}${secs}`;
  };

  const totalAmount = selectedSeatsList.reduce((total, seat) => {
    return total + seat.price;
  }, 0);

  const { data: stopsData, isLoading: isLoadingStops } = useQuery({
    queryKey: ['routeStops', selectedTrip?.route?.id],
    queryFn: async () => {
      if (!selectedTrip?.route?.id) return null;
      const upResponse = (await RouteService.getRouteStop({ routeId: selectedTrip.route.id, params: { type: "UP" } }))?.data?.result || [];
      const downResponse = (await RouteService.getRouteStop({ routeId: selectedTrip.route.id, params: { type: "DOWN" } }))?.data?.result || [];
      return { upResponse, downResponse };
    },
    enabled: !!selectedTrip?.route?.id
  });

  const upStops = stopsData?.upResponse || [];
  const downStops = stopsData?.downResponse || [];

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!formData.arrivalId || !formData.destinationId) {
      alert("Vui lòng chọn 1 điểm đón và 1 điểm trả!");
      return;
    }
    const payload = {
      ...formData,
      arrivalId: Number(formData.arrivalId),
      destinationId: Number(formData.destinationId),
      tripSeatIdList: selectedSeatsList.map((seat) => seat.id),
      id: bookingOrderId
    };
    onConfirm(payload);
  };

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
  };

  return (
    <>
      <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
        <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl overflow-hidden flex flex-col max-h-[95vh]">
          
          {/* Header */}
          <div className="flex justify-between items-center px-5 py-3 border-b border-gray-100 bg-gray-50/50">
            <div className="flex justify-between items-center gap-60">
              <div>
                <h2 className="text-xl font-bold text-gray-800">Thông tin đặt vé</h2>
                <p className="text-xs text-gray-500 mt-1">Vui lòng hoàn tất trong thời gian quy định</p>
              </div>
              
              {/* Bộ đếm ngược UI */}
              <div className={`flex  gap-1.5 px-3 py-1 rounded-full border ${timeLeft < 10 ? 'bg-red-100 border-red-300 text-red-600 animate-pulse' : 'bg-blue-100 border-blue-300 text-blue-600'}`}>
                <Timer size={20} />
                <span className="font-mono font-bold text-base">{formatTime(timeLeft)}</span>
              </div>
            </div>

            {/* Bấm X sẽ hiện ConfirmModal */}
            <button 
              onClick={() => setShowExitConfirm(true)} 
              className="p-2 hover:bg-gray-200 rounded-full transition-colors"
            >
              <X size={20} className="text-gray-600" />
            </button>
          </div>

          {/* Body */}
          <div className="px-6 py-2 overflow-y-auto flex-1 bg-white">
            <form id="booking-form" onSubmit={handleSubmit} className="space-y-3.5">
              
              {/* Danh sách ghế đã chọn */}
              <div className="bg-blue-50/50 p-3 rounded-xl border border-blue-100">
                <h3 className="text-sm font-semibold text-blue-900 mb-3 flex items-center gap-2">
                  <CreditCard size={16} /> Danh sách ghế đã chọn
                </h3>
                <div className="flex flex-wrap gap-2">
                  {selectedSeatsList.map((seat) => (
                    <span key={seat.id} className="px-3 py-1.5 bg-white border border-blue-200 text-blue-700 rounded-lg text-sm font-bold shadow-sm">
                      {seat.seatName}
                    </span>
                  ))}
                </div>
              </div>

              {/* Thông tin khách hàng */}
              <div className="space-y-3">
                <h3 className="text-sm font-semibold text-gray-700 border-l-4 border-blue-500 pl-2">Thông tin khách hàng</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="relative">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <User size={18} className="text-gray-400" />
                    </div>
                    <input type="text" name="customerName" value={formData.customerName} onChange={handleInputChange} required
                      className="w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                      placeholder="Họ và tên"
                    />
                  </div>
                  <div className="relative">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <Phone size={18} className="text-gray-400" />
                    </div>
                    <input type="tel" name="customerPhone" value={formData.customerPhone} onChange={handleInputChange} required
                      className="w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                      placeholder="Số điện thoại"
                    />
                  </div>
                  <div className="relative md:col-span-2">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <Mail size={18} className="text-gray-400" />
                    </div>
                    <input type="email" name="customerEmail" value={formData.customerEmail} onChange={handleInputChange} required
                      className="w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                      placeholder="Email nhận vé"
                    />
                  </div>
                </div>
              </div>

              {/* Điểm đón / Điểm trả */}
              <div className="space-y-3">
                <h3 className="text-sm font-semibold text-gray-700 border-l-4 border-emerald-500 pl-2">Hành trình</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-medium text-gray-500 mb-1">Điểm đón</label>
                    <div className="relative">
                      <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <MapPin size={18} className="text-emerald-500" />
                      </div>
                      <select name="arrivalId" value={formData.arrivalId} onChange={handleInputChange} required
                        className="w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg outline-none appearance-none bg-white"
                      >
                        <option value="" disabled>Chọn điểm đón</option>
                        {upStops.map((stop) => (
                          <option key={stop.id} value={stop.id}>{stop.stop.name}</option>
                        ))}
                      </select>
                    </div>
                  </div>
                  
                  <div>
                    <label className="block text-xs font-medium text-gray-500 mb-1">Điểm trả</label>
                    <div className="relative">
                      <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <MapPin size={18} className="text-rose-500" />
                      </div>
                      <select name="destinationId" value={formData.destinationId} onChange={handleInputChange} required
                        className="w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg outline-none appearance-none bg-white"
                      >
                        <option value="" disabled>Chọn điểm trả</option>
                        {downStops.map((stop) => (
                          <option key={stop.id} value={stop.id}>{stop.stop.name}</option>
                        ))}
                      </select>
                    </div>
                  </div>
                </div>
              </div>

              {/* Chi phí */}
              <div className="mt-2 border-t-2 border-dashed border-gray-200 pt-4">
                <div className="bg-gray-50 rounded-xl p-4 space-y-3">
                  <div className="flex justify-between text-gray-600">
                    <span className="text-sm">Số lượng vé:</span>
                    <span className="font-medium text-gray-900">{selectedSeatsList.length} vé</span>
                  </div>
                  <div className="flex justify-between items-center pt-2 border-t border-gray-200">
                    <span className="text-base font-bold text-gray-800 flex items-center gap-2">
                      <Banknote className="text-orange-500" size={20} /> Tổng thanh toán:
                    </span>
                    <span className="text-2xl font-black text-blue-600">
                      {formatCurrency(totalAmount)}
                    </span>
                  </div>
                </div>
              </div>
            </form>
          </div>

          {/* Footer */}
          <div className="p-5 border-t border-gray-100 bg-gray-50 flex justify-end gap-3">
            <button 
              type="button" 
              onClick={() => setShowExitConfirm(true)} // Mở modal xác nhận
              className="px-5 py-2.5 text-sm font-semibold text-gray-700 bg-white border border-gray-300 rounded-xl hover:bg-gray-50 transition-all"
            >
              Hủy bỏ
            </button>
            <button 
              type="submit" 
              form="booking-form"
              className="px-8 py-2.5 text-sm font-bold text-white bg-blue-600 rounded-xl hover:bg-blue-700 shadow-lg transition-all flex items-center gap-2"
            >
              Xác nhận đặt vé
            </button>
          </div>
        </div>
      </div>

      {/* 3. Component Xác nhận đóng Order */}
      <ConfirmModal 
        isOpen={showExitConfirm}
        onClose={() => setShowExitConfirm(false)}
        onConfirm={onClose} // Nếu xác nhận thì đóng BookingModal
        title="Hủy bỏ đặt vé"
        message="Bạn có chắc chắn muốn hủy quá trình đặt vé này không? Mọi thông tin đã nhập sẽ bị mất."
        confirmText="Đồng ý hủy"
        cancelText="Tiếp tục đặt"
        type="danger"
      />
    </>
  );
};

export default BookingModal;