import { X } from "lucide-react";
import React from "react";
const TripCreate = ({ setIsAddModalOpen }) => {
  return ( 
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="bg-white rounded-3xl shadow-2xl w-full max-w-2xl overflow-hidden flex flex-col max-h-[90vh]">
            
            <div className="flex items-center justify-between p-6 border-b border-slate-100">
              <h2 className="text-xl font-bold text-slate-900">Thêm chuyến đi mới</h2>
              <button 
                onClick={() => setIsAddModalOpen(false)}
                className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
              >
                <X size={20} />
              </button>
            </div>

            <div className="p-6 overflow-y-auto">
              <form className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2 md:col-span-2">
                  <label className="text-sm font-medium text-slate-700">Tuyến đường</label>
                  <select className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500">
                    <option value="">Chọn tuyến đường</option>
                    <option value="1">TP Hồ Chí Minh - Quảng Ngãi</option>
                    <option value="2">Đà Lạt - TP Hồ Chí Minh</option>
                  </select>
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium text-slate-700">Loại xe</label>
                  <select className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500">
                    <option value="">Chọn loại xe</option>
                    <option value="limousine">Limousine 34 giường</option>
                    <option value="sleeper">Giường nằm 40 chỗ</option>
                  </select>
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium text-slate-700">Giá vé (VNĐ)</label>
                  <input type="text" placeholder="VD: 350000" className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500" />
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium text-slate-700">Thời gian khởi hành</label>
                  <input type="datetime-local" className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500" />
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium text-slate-700">Trạng thái</label>
                  <select className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500">
                    <option value="Sắp khởi hành">Sắp khởi hành</option>
                    <option value="Đang chạy">Đang chạy</option>
                  </select>
                </div>
              </form>
            </div>

            <div className="p-6 border-t border-slate-100 bg-slate-50 flex justify-end gap-3 rounded-b-3xl">
              <button 
                onClick={() => setIsAddModalOpen(false)}
                className="px-5 py-2.5 text-sm font-medium text-slate-600 bg-white border border-slate-200 rounded-xl hover:bg-slate-50 transition-colors"
              >
                Hủy bỏ
              </button>
              <button className="px-5 py-2.5 text-sm font-medium text-white bg-emerald-600 rounded-xl hover:bg-emerald-700 transition-colors shadow-sm shadow-emerald-600/20">
                Lưu chuyến đi
              </button>
            </div>
          </div>
    </div>
  );
};

export default TripCreate;
