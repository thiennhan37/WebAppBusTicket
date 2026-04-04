import React, { useEffect, useRef } from 'react';
import { CheckCircle, XCircle, X } from 'lucide-react'; 

const StatusModal = ({ type = "success", message, onClose }) => {
  const modalRef = useRef();

  // Xử lý khi click ra ngoài vùng trắng của Modal
  const handleOverlayClick = (e) => {
    if (modalRef.current && !modalRef.current.contains(e.target)) {
      onClose();
    }
  };

  // Đóng modal khi nhấn phím ESC
  useEffect(() => {
    const handleEsc = (e) => {
      if (e.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', handleEsc);
    return () => window.removeEventListener('keydown', handleEsc);
  }, [onClose]);

  const isSuccess = type === 'success';

  return (
    // Overlay trong suốt (hoặc mờ cực nhẹ)
    <div 
      className="absolute inset-0 z-[999] flex items-center justify-center p-4"
      onClick={handleOverlayClick}
    >
      <div 
        ref={modalRef}
        className="relative w-full max-w-sm bg-white rounded-2xl shadow-2xl p-6 border border-gray-100 animate-in fade-in zoom-in duration-200"
      >
        {/* Nút đóng góc trên */}
        <button 
          onClick={onClose}
          className="absolute top-4 right-4 text-gray-400 hover:text-gray-600 transition-colors"
        >
          <X size={20} />
        </button>

        <div className="flex flex-col items-center text-center">
          {/* Icon */}
          <div className={`mb-4 p-3 rounded-full ${isSuccess ? 'bg-green-100' : 'bg-red-100'}`}>
            {isSuccess ? (
              <CheckCircle size={40} className="text-green-600" />
            ) : (
              <XCircle size={40} className="text-red-600" />
            )}
          </div>

          {/* Nội dung */}
          <h3 className="text-lg font-bold text-gray-900">
            {isSuccess ? "Thành công!" : "Đã xảy ra lỗi"}
          </h3>
          <p className="mt-2 text-gray-500">
            {message}
          </p>
        </div>
      </div>
    </div>
  );
};

export default StatusModal;