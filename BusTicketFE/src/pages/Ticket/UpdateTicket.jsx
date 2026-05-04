import React, { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import validator from 'validator';
import { X, MapPin} from 'lucide-react'; 
import RouteService from '../../Services/routeService';

const BookingModal = ({selectedTrip,  seat, onClose, onSubmit}) => {
  const [phoneError, setPhoneError] = useState('');
  const [formData, setFormData] = useState({
      ticketId: seat.ticket.id, 
      customerName: '',
      customerPhone: '',
      arrivalId: '',
      destinationId: ''
    });

  const { data: stopsData, isLoading: isLoadingStops } = useQuery({
    queryKey: ['routeStops', selectedTrip?.route?.id],
    queryFn: async () => {
      if (!selectedTrip?.route?.id) return null;
      const upResponse = (await RouteService.getRouteStop({ routeId: selectedTrip.route.id, params: { type: "UP" } }))?.data?.result || [];
      const downResponse = (await RouteService.getRouteStop({ routeId: selectedTrip.route.id, params: { type: "DOWN" } }))?.data?.result || [];
      console.log(upResponse, downResponse);
      return { upResponse, downResponse };
    },
    enabled: !!selectedTrip?.route?.id
  });

  const upStops = stopsData?.upResponse || [];
  const downStops = stopsData?.downResponse || [];

  const handleInputChange = (e) => {
    let { name, value } = e.target;
    if(name === "customerPhone") value = value.trim();
    setFormData((prev) => ({ ...prev, [name]: value }));
  };
  // Validate khi mất focus (onBlur)
  const handlePhoneBlur = () => {
    let message = "";
    if(!formData.customerPhone || validator.isMobilePhone(formData.customerPhone, "vi-VN")) message = "";
    else message = "Số điện thoại không hợp lệ";
    setPhoneError(message);
  };

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
      <div className="bg-white w-[600px] rounded-xl shadow-xl flex flex-col overflow-hidden">
        {/* Header Modal */}
        <div className="bg-blue-600 text-white px-4 py-3 flex justify-between items-center">
          <h3 className="font-semibold">{`Cập nhật thông tin - Ghế ${seat.seatName} - 
          Mã [${seat?.id}]`}</h3>
          <button onClick={onClose} className="text-white/80 hover:text-white">✕</button>
        </div>

        {/* Body Modal */}
        <div className="p-6 grid grid-cols-2 gap-4 flex-1 overflow-y-auto">
          <div className="col-span-2 sm:col-span-1">
            <label className="block text-sm font-medium text-gray-700 mb-1">SĐT Người đặt <span className="text-red-500">*</span></label>
            <input 
              type="text" 
              value={formData.customerPhone}
              name="customerPhone"
              onChange={handleInputChange}
              onBlur={handlePhoneBlur}
              className={`w-full border ${phoneError ? 'border-red-500' : 'border-gray-200'} rounded-lg px-3 py-2 outline-none focus:border-blue-500`}
              placeholder="Nhập SĐT..."
            />
            {phoneError && <p className="text-red-500 text-xs mt-1">{phoneError}</p>}
          </div>

          <div className="col-span-2 sm:col-span-1">
            <label className="block text-sm font-medium text-gray-700 mb-1">Tên khách hàng</label>
            <input 
              value={formData.customerName} 
              name="customerName"
              onChange={handleInputChange}
              type="text" 
              className="w-full border border-gray-200 rounded-lg px-3 py-2 outline-none focus:border-blue-500"
              placeholder="Nhập tên..."
            />
          </div>
        </div>

        {/* Điểm đón / Điểm trả */}
        <div className="space-y-3 px-4">
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

        {/* Footer Modal */}
        <div className="bg-gray-50 border-t border-gray-100 px-4 py-3 flex justify-end gap-2">
          <button onClick={onClose} className="px-4 py-2 bg-white border border-gray-200 text-gray-700 rounded-lg hover:bg-gray-50 transition">
            Hủy
          </button>
          <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition shadow-sm"
            onClick={() => {
              if(!phoneError) onSubmit(formData);
            }}>
            Cập nhật
          </button>
        </div>
      </div>
    </div>
  );
}

export default BookingModal;