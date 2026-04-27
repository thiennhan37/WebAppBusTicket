import React, { useState } from 'react';

const BookingModal = ({ seat, onClose }) => {
  const [phone, setPhone] = useState('');
  const [phoneError, setPhoneError] = useState('');

  // Validate khi mất focus (onBlur)
  const handlePhoneBlur = () => {
    if (!phone) {
      setPhoneError('Vui lòng nhập số điện thoại');
    } else if (phone.length < 10) {
      setPhoneError('Số điện thoại không hợp lệ');
    } else {
      setPhoneError('');
    }
  };

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
      <div className="bg-white w-[600px] rounded-xl shadow-xl flex flex-col overflow-hidden">
        {/* Header Modal */}
        <div className="bg-blue-600 text-white px-4 py-3 flex justify-between items-center">
          <h3 className="font-semibold">Cập nhật thông tin - Ghế {seat?.id}</h3>
          <button onClick={onClose} className="text-white/80 hover:text-white">✕</button>
        </div>

        {/* Body Modal */}
        <div className="p-6 grid grid-cols-2 gap-4 flex-1 overflow-y-auto">
          <div className="col-span-2 sm:col-span-1">
            <label className="block text-sm font-medium text-gray-700 mb-1">SĐT Người đặt <span className="text-red-500">*</span></label>
            <input 
              type="text" 
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              onBlur={handlePhoneBlur}
              className={`w-full border ${phoneError ? 'border-red-500' : 'border-gray-200'} rounded-lg px-3 py-2 outline-none focus:border-blue-500`}
              placeholder="Nhập SĐT..."
            />
            {phoneError && <p className="text-red-500 text-xs mt-1">{phoneError}</p>}
          </div>

          <div className="col-span-2 sm:col-span-1">
            <label className="block text-sm font-medium text-gray-700 mb-1">Tên khách hàng</label>
            <input 
              type="text" 
              className="w-full border border-gray-200 rounded-lg px-3 py-2 outline-none focus:border-blue-500"
              placeholder="Nhập tên..."
            />
          </div>

          <div className="col-span-2">
            <label className="block text-sm font-medium text-gray-700 mb-1">Ghi chú</label>
            <textarea 
              rows="3"
              className="w-full border border-gray-200 rounded-lg px-3 py-2 outline-none focus:border-blue-500"
              placeholder="Ghi chú thêm..."
            ></textarea>
          </div>
        </div>

        {/* Footer Modal */}
        <div className="bg-gray-50 border-t border-gray-100 px-4 py-3 flex justify-end gap-2">
          <button onClick={onClose} className="px-4 py-2 bg-white border border-gray-200 text-gray-700 rounded-lg hover:bg-gray-50 transition">
            Hủy
          </button>
          <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition shadow-sm">
            Cập nhật
          </button>
        </div>
      </div>
    </div>
  );
}

export default BookingModal;