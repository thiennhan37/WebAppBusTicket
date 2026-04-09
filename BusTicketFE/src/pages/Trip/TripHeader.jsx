import React from 'react';
import { Search, Plus, Calendar, Filter } from 'lucide-react';

const TripHeader = ({ setIsAddModalOpen, searchQuery, setSearchQuery }) => {
    return (
    <div>
        {/* Header Section */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-2 gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Danh sách chuyến đi</h1>
          <p className="text-sm text-slate-500 mt-1">Quản lý lịch trình, xe và giá vé các chuyến đi</p>
        </div>
        <button 
          onClick={() => setIsAddModalOpen(true)}
          className="flex items-center justify-center gap-2 bg-emerald-600 hover:bg-emerald-700 text-white px-5 py-2.5 rounded-xl font-medium transition-colors shadow-sm shadow-emerald-600/20 active:scale-95"
        >
          <Plus size={20} />
          <span>Thêm chuyến đi</span>
        </button>
      </div>

      {/* Filter & Search Bar - App-like card */}
      <div className="bg-white py-2 px-4 rounded-2xl shadow-sm border border-slate-100 mb-0 flex flex-col sm:flex-row gap-4">
        <div className="relative flex-1">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <Search size={18} className="text-slate-400" />
          </div>
          <input 
            type="text" 
            placeholder="Tìm kiếm theo ID, Tuyến đường..." 
            className="block w-full pl-10 pr-3 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 transition-all"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
        <div className="flex gap-3">
          <button className="flex items-center gap-2 px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium text-slate-600 hover:bg-slate-100 transition-colors">
            <Calendar size={18} />
            <span className="hidden sm:inline">Ngày đi</span>
          </button>
          <button className="flex items-center gap-2 px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium text-slate-600 hover:bg-slate-100 transition-colors">
            <Filter size={18} />
            <span className="hidden sm:inline">Lọc</span>
          </button>
        </div>
      </div>
    </div>
          
    )
};

export default TripHeader;
