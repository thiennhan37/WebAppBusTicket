import React from 'react';

const PaymentSuccess = () => {
  return (
    <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4 antialiased font-sans">
      <div className="bg-white rounded-2xl shadow-xl max-w-md w-full p-6 md:p-8 transform transition-all duration-300 hover:shadow-2xl">
        
        {/* Success Icon Animation */}
        <div className="flex flex-col items-center justify-center text-center">
          <div className="w-20 h-20 bg-green-50 rounded-full flex items-center justify-center mx-auto mb-4 animate-bounce">
            <svg 
              className="w-12 h-12 text-green-500" 
              fill="none" 
              stroke="currentColor" 
              viewBox="0 0 24 24" 
              xmlns="http://www.w3.org/2000/svg"
            >
              <path 
                strokeLinecap="round" 
                strokeLinejoin="round" 
                strokeWidth="3" 
                d="M5 13l4 4L19 7"
              ></path>
            </svg>
          </div>
          
          <h1 className="text-2xl font-bold text-slate-800 mb-2">
            Thanh Toán Thành Công!
          </h1>
          <p className="text-sm text-slate-500 mb-6">
            Cảm ơn bạn đã tin tưởng dịch vụ của chúng tôi. Hóa đơn điện tử đã được gửi về email của bạn.
          </p>
        </div>
        <button 
            onClick={() => window.location.href = '/nhaxe/overview'}
            className="w-full bg-emerald-500 hover:bg-emerald-600 text-white font-semibold py-3 px-4 rounded-xl shadow-md shadow-emerald-200 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-emerald-400 focus:ring-offset-2"
        >
            Quay lại trang chủ
        </button>

        {/* Footer Support Info */}
        <div className="mt-6 text-center">
          <p className="text-xs text-slate-400">
            Gặp sự cố? <a href="/support" className="text-emerald-500 hover:underline font-medium">Liên hệ hỗ trợ</a>
          </p>
        </div>

      </div>
    </div>
  );
};

export default PaymentSuccess;