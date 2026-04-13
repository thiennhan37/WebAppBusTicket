import React, { useState, useRef, useEffect, useContext } from 'react';
import { LogOut, User, Settings, AlertTriangle, X } from 'lucide-react';
import AuthContext from '../../context/AuthContext';
import AuthenticateService from '../../Services/authenticate';

const UserProfile = () => {
  const { user, logout, company } = useContext(AuthContext);
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [showLogoutModal, setShowLogoutModal] = useState(false);
  const menuRef = useRef(null);

  // Đóng menu nhỏ khi click ra ngoài
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (menuRef.current && !menuRef.current.contains(event.target)) {
        setIsMenuOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);
  const handleLogout = () => {
    const accessToken = localStorage.getItem("accessToken");
    AuthenticateService.logout({accessToken});
    logout();
  }
  return (
    <div className="relative p-4 border-t-2 border-slate-200 bg-gray-50/50" ref={menuRef}>
      
      {/* 1. DROPDOWN MENU NHỎ (Hiện khi bấm vào User) */}
      {isMenuOpen && (
        <div className="absolute bottom-full left-4 mb-2 w-52 bg-white rounded-xl shadow-2xl border border-gray-100 py-2 z-40 animate-in fade-in slide-in-from-bottom-2">
          {/* <button className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors">
            <User size={18} className="text-gray-400" /> Hồ sơ cá nhân
          </button>
          <hr className="my-1 border-gray-100" /> */}
          <button 
            onClick={() => {
              setIsMenuOpen(false); 
              setShowLogoutModal(true); 
            }}
            className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-red-600 hover:bg-red-50 transition-colors font-medium"
          >
            <LogOut size={18} /> Đăng xuất
          </button>
        </div>
      )}

      {/* 2. LỚP PHỦ MỜ VÀ MODAL XÁC NHẬN (LOGOUT MODAL) */}
      {showLogoutModal && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
          {/* Lớp nền mờ (Overlay) */}
          <div 
            className="absolute inset-0 bg-slate-900/60 backdrop-blur-sm animate-in fade-in duration-300"
            onClick={() => setShowLogoutModal(false)} // Bấm ra ngoài để hủy
          ></div>

          {/* Hộp thoại xác nhận (Modal Content) */}
          <div className="relative bg-white rounded-2xl p-6 w-full max-w-sm shadow-2xl animate-in zoom-in-95 duration-200">
            <div className="flex flex-col items-center text-center">
              <div className="w-16 h-16 bg-red-50 rounded-full flex items-center justify-center mb-4">
                <AlertTriangle className="text-red-500" size={32} />
              </div>
              
              <h3 className="text-xl font-bold text-gray-900 mb-2">Xác nhận đăng xuất</h3>
              <p className="text-gray-500 mb-8 leading-relaxed">
                Bạn có chắc chắn muốn rời khỏi hệ thống? Mọi thay đổi chưa lưu có thể bị mất.
              </p>

              <div className="flex gap-3 w-full">
                <button 
                  onClick={() => setShowLogoutModal(false)}
                  className="flex-1 px-4 py-2.5 rounded-xl border border-gray-200 text-gray-700 font-semibold hover:bg-gray-50 transition-all active:scale-95"
                >
                  Hủy bỏ
                </button>
                <button 
                  onClick={() => {handleLogout()}}
                  className="flex-1 px-4 py-2.5 rounded-xl bg-red-600 text-white font-semibold hover:bg-red-700 shadow-lg shadow-red-200 transition-all active:scale-95"
                >
                  Đăng xuất
                </button>
              </div>
            </div>

            {/* Nút đóng nhanh (X) */}
            <button 
              onClick={() => setShowLogoutModal(false)}
              className="absolute top-4 right-4 text-gray-400 hover:text-gray-600"
            >
              <X size={20} />
            </button>
          </div>
        </div>
      )}

      {/* 3. TRIGGER (Thông tin User ở Sidebar) */}
      <div 
        onClick={() => setIsMenuOpen(!isMenuOpen)}
        className="flex items-center gap-3 p-2 rounded-xl hover:bg-gray-200/50 cursor-pointer transition-all active:scale-95"
      >
        <div className="w-10 h-10 shrink-0 rounded-full bg-blue-600 flex items-center justify-center text-white font-bold">
          {user?.fullName?.[0].toUpperCase()}
        </div>
        <div className="flex flex-col overflow-hidden text-left">
          <span className="text-sm font-bold text-gray-800 truncate">{user?.email}</span>
          <span className="text-xs text-gray-500 truncate">{company?.companyName}</span>
        </div>
      </div>
    </div>
  );
};

export default UserProfile;