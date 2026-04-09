import React, { useState } from 'react';
import { MapPin, Clock, Bus, Tag, MoreVertical } from 'lucide-react';
import TripHeader from './TripHeader';
import TripCreate from './TripCreate';
import Pagination from '../../components/other/Pagination';
const Trips = () =>{
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

  // Dữ liệu mẫu
  const [trips, setTrips] = useState([
    { id: 'CX-001', route: 'TP Hồ Chí Minh - Quảng Ngãi', vehicle: 'Limousine 34 giường', status: 'Sắp khởi hành', time: '19:00 - 20/05/2026', price: '450.000đ' },
    { id: 'CX-002', route: 'Đà Lạt - TP Hồ Chí Minh', vehicle: 'Giường nằm 40 chỗ', status: 'Đang chạy', time: '22:30 - 19/05/2026', price: '300.000đ' },
    { id: 'CX-003', route: 'Quảng Ngãi - Đà Nẵng', vehicle: 'Ghế ngồi 29 chỗ', status: 'Đã hoàn thành', time: '07:00 - 18/05/2026', price: '150.000đ' },
      { id: 'CX-004', route: 'Quảng Ngãi - Đà Nẵng', vehicle: 'Ghế ngồi 29 chỗ', status: 'Đã hoàn thành', time: '07:00 - 18/05/2026', price: '150.000đ' },
    { id: 'CX-005', route: 'Quảng Ngãi - Đà Nẵng', vehicle: 'Ghế ngồi 29 chỗ', status: 'Đã hoàn thành', time: '07:00 - 18/05/2026', price: '150.000đ' },

]);

  // Hàm render màu sắc badge trạng thái
  const getStatusBadge = (status) => {
    switch (status) {
      case 'Sắp khởi hành': return 'bg-amber-100 text-amber-700 border-amber-200';
      case 'Đang chạy': return 'bg-blue-100 text-blue-700 border-blue-200';
      case 'Đã hoàn thành': return 'bg-gray-100 text-gray-600 border-gray-200';
      default: return 'bg-gray-100 text-gray-600 border-gray-200';
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 p-6 font-sans text-slate-800">
      <TripHeader
        setIsAddModalOpen={setIsAddModalOpen}
        searchQuery={searchQuery}
        setSearchQuery={setSearchQuery}
      />

      {/* Data List - App-like Cards for Mobile, Table for Desktop */}
      <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-50 border-b border-slate-100 text-xs uppercase tracking-wider text-slate-500">
                <th className="px-6 py-3 font-semibold">Chuyến đi</th>
                <th className="px-6 py-3 font-semibold">Thời gian</th>
                <th className="px-6 py-3 font-semibold">Phương tiện & Giá</th>
                <th className="px-6 py-3 font-semibold">Trạng thái</th>
                <th className="px-6 py-3 font-semibold text-right">Thao tác</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {trips.map((trip) => (
                <tr key={trip.id} className="hover:bg-slate-50/50 transition-colors group">
                  <td className="px-6 py-3">
                    <div className="flex items-start gap-3">
                      <div className="mt-1 bg-emerald-100 p-2 rounded-lg text-emerald-600">
                        <MapPin size={18} />
                      </div>
                      <div>
                        <div className="font-semibold text-slate-900">{trip.route}</div>
                        <div className="text-sm text-slate-500 mt-0.5">ID: {trip.id}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-3">
                    <div className="flex items-center gap-2 text-slate-700">
                      <Clock size={16} className="text-slate-400" />
                      <span className="text-sm font-medium">{trip.time.split(' - ')[0]}</span>
                    </div>
                    <div className="text-sm text-slate-500 mt-1 pl-6">{trip.time.split(' - ')[1]}</div>
                  </td>
                  <td className="px-6 py-3">
                    <div className="flex items-center gap-2 text-slate-700">
                      <Bus size={16} className="text-slate-400" />
                      <span className="text-sm">{trip.vehicle}</span>
                    </div>
                    <div className="flex items-center gap-2 text-emerald-600 font-semibold mt-1">
                      <Tag size={16} />
                      <span>{trip.price}</span>
                    </div>
                  </td>
                  <td className="px-6 py-3">
                    <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium border ${getStatusBadge(trip.status)}`}>
                      {trip.status}
                    </span>
                  </td>
                  <td className="px-6 py-3 text-right">
                    <button className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-lg transition-colors">
                      <MoreVertical size={20} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add Trip Modal (Slide-up or Center Pop) */}
      {isAddModalOpen && (
        <TripCreate setIsAddModalOpen={setIsAddModalOpen} />
      )}
      <Pagination></Pagination>
    </div>
  );
}

export default Trips;