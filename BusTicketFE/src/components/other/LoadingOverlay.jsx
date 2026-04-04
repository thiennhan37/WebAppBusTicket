import React from 'react';

const LoadingOverlay = ({ message = "Đang xử lý dữ liệu..." }) => {
  return (
    <div className="absolute inset-0 z-[100] flex flex-col items-center justify-center bg-black/40 backdrop-blur-[2px]">
      {/* Vòng xoay Spinner */}
      <div className="relative flex items-center justify-center">
        <div className="h-16 w-16 animate-spin rounded-full border-4 border-solid border-blue-600 border-t-transparent"></div>
        {/* Một vòng tròn phụ bên trong cho đẹp (tùy chọn) */}
        <div className="absolute h-10 w-10 animate-ping rounded-full bg-blue-400 opacity-20"></div>
      </div>
      
      {/* Thông báo bên dưới */}
      <p className="mt-4 font-medium text-white drop-shadow-md">
        {message}
      </p>
    </div>
  );
};

export default LoadingOverlay;